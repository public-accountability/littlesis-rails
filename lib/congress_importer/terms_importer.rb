# frozen_string_literal: true

class CongressImporter
  class TermsImporter
    attr_internal :legislator, :distilled_terms
    DistilledTerms = Struct.new(:rep, :sen)

    TERM_TYPE_TO_ENTITY = { 'rep' => 12_884, 'sen' => 12_885 }.freeze
    TERM_TYPE_TO_DESCRIPTION = { 'rep' => 'Representative', 'sen' => 'Senator' }.freeze
    PARTY_TO_ENTITY = { 'Democrat' => 12_886, 'Republican' => 12_901 }.freeze

    HOUSE_QUERY = { entity2_id: 12_884, category_id: 3 }.freeze
    SENATE_QUERY = { entity2_id: 12_885, category_id: 3 }.freeze

    def initialize(legislator)
      @_legislator = legislator
      @_distilled_terms = DistilledTerms.new(distilled_rep_terms, distilled_sen_terms)
      @entity = legislator.legislator_matcher.entity
      unless @entity
        raise Exceptions::LittleSisError, "Could not find a matching entity for #{legislator}"
      end
    end

    # Updates existing relationships with House and Senate and/or creates
    # new ones if they don't yet exit.
    # It will match existing relationships based on their 'start-date',
    # and afterwards prune relationships as neeeded.
    def import!
      CongressImporter.transaction do
        rep_relationships = @entity.relationships.where(HOUSE_QUERY).to_a
        sen_relationships = @entity.relationships.where(SENATE_QUERY).to_a

        distilled_terms.rep.each do |term|
          rel = rep_relationships.find(&same_start_date_proc(term['start']))
          update_or_create_relationship term, relationship: rel
        end

        distilled_terms.sen.each do |term|
          rel = sen_relationships.find(&same_start_date_proc(term['start']))
          update_or_create_relationship term, relationship: rel
        end
        @entity.reload
        prune_all_relationships!
      end
    end

    def import_party_memberships!
      p_memberships = party_memberships
      republican_memberships = p_memberships.select { |m| m['party'] == 'Republican' }
      democrat_memberships = p_memberships.select { |m| m['party'] == 'Democrat' }

      if republican_memberships.count.positive?
        membership = find_party_memberships(NotableEntities.fetch(:republican_party)).first
        update_party_membership(republican_memberships.last, membership)
      end

      if democrat_memberships.count.positive?
        membership = find_party_memberships(NotableEntities.fetch(:democratic_party)).first
        update_party_membership(democrat_memberships.last, membership)
      end
    end

    private

    def update_party_membership(membership, relationship)
      relationship = Relationship.new if relationship.blank?

      relationship.update!(category_id: Relationship::MEMBERSHIP_CATEGORY,
                           entity1_id: @entity.id,
                           entity2_id: PARTY_TO_ENTITY.fetch(membership['party']),
                           last_user_id: CongressImporter::CONGRESS_BOT_USER)
    end

    def find_party_memberships(party_id)
      @entity
        .relationships
        .reload
        .where(category_id: Relationship::MEMBERSHIP_CATEGORY, entity2_id: party_id)
        .order('updated_at desc')
    end

    def update_or_create_relationship(term, relationship: nil)
      relationship = Relationship.new if relationship.blank?

      relationship.update!(category_id: Relationship::MEMBERSHIP_CATEGORY,
                           entity1_id: @entity.id,
                           entity2_id: TERM_TYPE_TO_ENTITY.fetch(term['type']),
                           description1: TERM_TYPE_TO_DESCRIPTION.fetch(term['type']),
                           description2: TERM_TYPE_TO_DESCRIPTION.fetch(term['type']),
                           start_date: term['start'],
                           end_date: term['end'],
                           is_current: (Date.parse(term['end']) > Date.today),
                           last_user_id: CongressImporter::CONGRESS_BOT_USER)
      relationship.membership.update!(elected_term: elected_term_hash(term))
    end

    def elected_term_hash(term)
      term.merge('source' => '@unitedstates').stringify_keys!
    end

    def prune_all_relationships!
      delete_if_nil = proc { |r| r.soft_delete if r.membership.elected_term['type'].nil? }

      if @entity.relationships.where(HOUSE_QUERY).count > distilled_rep_terms.count
        @entity.relationships.where(HOUSE_QUERY).each(&delete_if_nil)
      end

      if @entity.relationships.where(SENATE_QUERY).count > distilled_sen_terms.count
        @entity.relationships.where(SENATE_QUERY).each(&delete_if_nil)
      end
    end

    # Reduces the list of terms into a list of consecutive periods in office.
    def distill(terms, distinct_terms = [])
      return distinct_terms if terms.empty?
      return distill(terms.drop(1), Array.wrap(terms.first.deep_dup)) if distinct_terms.empty?

      if within_one_month(terms.first['start'], distinct_terms.last['end'])
        if equivalent?(terms.first, distinct_terms.last)
          new_term = terms.first.deep_dup.merge('start' => distinct_terms.last['start'])
          return distill terms.drop(1), distinct_terms.take(distinct_terms.length - 1).push(new_term)
        end
      end
      return distill terms.drop(1), distinct_terms.push(terms.first.deep_dup)
    end

    # defines methods: rep_terms, distilled_rep_terms, sen_terms, distilled_sen_terms
    %w[rep sen].each do |type|
      define_method "#{type}_terms" do
        legislator['terms'].select { |t| t['type'] == type }.sort_by { |t| t['start'] }
      end

      define_method "distilled_#{type}_terms" do
        distill send("#{type}_terms")
      end
    end

    def party_memberships
      distill_party_memberships legislator['terms']
    end

    def distill_party_memberships(terms, p_memberships = [])
      return p_memberships if terms.empty?

      unless %w[Republican Democrat].include?(terms.first['party'])
        return distill_party_memberships(terms.drop(1), p_memberships)
      end

      if p_memberships.empty? || terms.first['party'] != p_memberships.last['party']
        membership = terms.first.deep_dup.slice('party', 'start', 'end')
        return distill_party_memberships(terms.drop(1), p_memberships.push(membership))
      else
        membership = terms.first.deep_dup
                       .slice('party', 'start', 'end')
                       .merge('start' => p_memberships.last['start'])

        return distill_party_memberships(terms.drop(1),
                                         p_memberships.take(p_memberships.length - 1).push(membership))
      end
    end

    #######################
    # Comparision helpers #
    #######################

    # str --> proc
    def same_start_date_proc(date)
      proc { |r| same_start_date(r.start_date, date) }
    end

    # str, str --> boolean
    def same_start_date(relationship_date, term_date)
      ls_date = LsDate.new(relationship_date)
      # if the current relationship's date only has year information, compare years
      return (ls_date.year == term_date.slice(0, 4).to_i) if ls_date.sp_year?

      within_one_month(ls_date.coerce_to_date_str, term_date)
    end

    # str, str --> boolean
    def within_one_month(date_one, date_two)
      (Date.parse(date_one) - Date.parse(date_two)).to_i.abs <= 30
    end

    # Hash, Hash (terms) --> boolean
    def equivalent?(a, b)
      a['state'].eql?(b['state']) && a['district'].eql?(b['district']) && a['party'].eql?(b['party'])
    end
  end
end

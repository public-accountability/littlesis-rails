# frozen_string_literal: true

class LegislatorMatcher
  class TermsImporter
    attr_internal :legislator, :distilled_terms
    DistilledTerms = Struct.new(:rep, :sen)

    TERM_TYPE_TO_ENTITY = { 'rep' => 12_884, 'sen' => 12_885 }.freeze
    TERM_TYPE_TO_DESCRIPTION = { 'rep' => 'Representative', 'sen' => 'Senator' }.freeze

    def initialize(legislator)
      @_legislator = legislator
      @_distilled_terms = DistilledTerms.new(distilled_rep_terms, distilled_sen_terms)
    end

    # If there are no existing relationsips
    # this will create all new relationsips.
    # Otherwise it will match relationships based on their 'start-date'
    # and update them accordingly.
    def import!
      rep_relationships = legislator.entity.relationships.where(entity2_id: LegislatorMatcher::HOUSE_OF_REPS).to_a
      sen_relationships = legislator.entity.relationships.where(entity2_id: LegislatorMatcher::SENATE).to_a

      distilled_terms.rep.each do |term|
        rel = rep_relationships.select { |r| same_start_date(r.start_date, term['start']) }.first
        update_or_create_relationship term, relationship: rel
      end

      distilled_terms.sen.each do |term|
        rel = sen_relationships.select { |r| same_start_date(r.start_date, term['start']) }.first
        update_or_create_relationship term, relationship: rel
      end

      verify_all_relationships!
    end

    private

    def update_or_create_relationship(term, relationship: nil)
      relationship = Relationship.new unless relationship.present?
      relationship.update!(category_id: Relationship::MEMBERSHIP_CATEGORY,
                           entity1_id: legislator.entity.id,
                           entity2_id: TERM_TYPE_TO_ENTITY.fetch(term['type']),
                           description1: TERM_TYPE_TO_DESCRIPTION.fetch(term['type']),
                           description2: TERM_TYPE_TO_DESCRIPTION.fetch(term['type']),
                           start_date: term['start'],
                           end_date: term['end'],
                           last_user_id: LegislatorMatcher::CONGRESS_BOT_SF_USER)
      relationship.membership.update!(elected_term: elected_term_struct(term))
    end

    def elected_term_struct(term)
      OpenStruct.new term.merge('source' => '@unitedstates')
    end

    def verify_all_relationships!
      legislator.entity.reload

      if legislator.entity.relationships.where(entity2_id: LegislatorMatcher::HOUSE_OF_REPS).count > distilled_rep_terms.count
        legislator.entity.relationships.where(entity2_id: LegislatorMatcher::HOUSE_OF_REPS).each do |r|
          r.soft_delete if r.membership.elected_term.type.nil?
        end
      end

      if legislator.entity.relationships.where(entity2_id: LegislatorMatcher::SENATE).count > distilled_sen_terms.count
        legislator.entity.relationships.where(entity2_id: LegislatorMatcher::SENATE).each do |r|
          r.soft_delete if r.membership.elected_term.type.nil?
        end
      end
    end

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

    #######################
    # Comparision helpers #
    #######################

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

    def equivalent?(a, b)
      a['state'].eql?(b['state']) && a['district'].eql?(b['district']) && a['party'].eql?(b['party'])
    end
  end
end



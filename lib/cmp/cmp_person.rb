# frozen_string_literal: true

module Cmp
  class CmpPerson < CmpEntityImporter
    ATTRIBUTE_MAP = {
      fullname: [:entity, :name],
      date_of_birth: [:entity, :start_date],
      salutation: [:person, :name_prefix],
      firstname: [:person, :name_first],
      middlename: [:person, :name_middle],
      lastname: [:person, :name_last],
      suffix: [:person, :name_suffix],
      gender_id: [:person, :gender_id]
    }.freeze

    def initialize(*args)
      super(*args)
      update_date_of_birth
      @attributes[:gender_id] = Person.gender_to_id(fetch('gender'))
    end

    def import!(preselected = nil)
      Rails.logger.info "Importing: #{cmpid}"

      Cmp.transaction do
        if preselected.nil?
          entity = find_or_create_entity
        elsif preselected == :new
          entity = create_new_entity!
        elsif /^\d+$/.match?(preselected)
          entity = Entity.find(preselected)
        else
          raise "Invalid preselected input: #{preselected}"
        end

        CmpEntity.find_or_create_by!(entity: entity, cmp_id: cmpid, entity_type: :person)

        entity.add_tag(Cmp::CMP_TAG_ID, Cmp::CMP_USER_ID)
        add_alias(entity)
        entity.update!(start_date: fetch('date_of_birth'))
        entity.person.update! attrs_for(:person)
        if fetch('nationality').present?
          fetch('nationality').split(';').each do |place|
            entity.person.add_nationality(place)
          end
          entity.person.save!
        end
      end
    end

    # importing helpers

    def find_or_create_entity
      entity = CmpEntity.find_by(cmp_id: cmpid, entity_type: :person)&.entity
      return entity if entity.present?

      if preselected_match
        if preselected_match.to_s.casecmp('NEW').zero?
          return create_new_entity!
        else
          return Entity.find(preselected_match)
        end
      end

      return matches.first.entity if matches.automatchable?
      return create_new_entity!
    end

    # -> <Entity>
    def create_new_entity!
      Entity.create!(primary_ext: 'Person', name: name_for_entity, last_user_id: Cmp::CMP_USER_ID)
    end

    def name_for_entity
      first = fetch('firstname')
      middle = fetch('middlename', nil).blank? ? '' : " #{fetch('middlename')}"
      last = fetch('lastname')
      "#{first}#{middle} #{last}"
    end

    def preselected_match
      Cmp::EntityMatch.matches.dig(cmpid.to_s, 'entity_id')
    end

    # utilites to find matches

    def cmp_relationships
      @cmp_relationships ||= Cmp::Datasets
                               .relationships
                               .select { |r| r['cmp_person_id'] == cmpid }
    end

    def cmp_relationships_with_title
      cmp_relationships.map do |cmp_r|
        org_name = Cmp::Datasets
                     .orgs
                     .find { |org| org.cmpid == cmp_r['cmp_org_id'].to_i }
                     &.fetch('cmpname')

        if org_name.nil?
          ''
        elsif cmp_r['job_title'].blank?
          org_name
        else
          "#{org_name} (#{cmp_r['job_title']})"
        end
      end
    end

    # --> [String]
    def related_cmp_org_names
      related_cmp_org_ids.map do |cmp_id|
        Cmp::Datasets.orgs
          .find { |org| org.cmpid == cmp_id }
          .fetch('cmpname')
      end
    end

    # --> [Int]
    def related_cmp_org_ids
      cmp_relationships.map { |r| r['cmp_org_id'].to_i }
    end

    def associated_entity_ids
      return [] if related_cmp_org_ids.empty?
      CmpEntity
        .where(cmp_id: related_cmp_org_ids)
        .distinct
        .pluck('entity_id')
    end

    def matches
      h = to_person_hash
      unless (h[:name_first] || h['name_first']) && (h[:name_last] || h['name_last'])
        Rails.logger.warn "#{cmpid} is missing a first or last name!"
        return EntityMatcher::EvaluationResultSet.new([])
      end

      return @matches unless @matches.nil?

      @matches = EntityMatcher
                   .find_matches_for_person(to_person_hash, associated: associated_entity_ids)
    end

    def clear_matches
      @matches = nil
      self
    end

    def update_date_of_birth
      @attributes[:date_of_birth] = nil

      dates = [@attributes['dob_2015'], @attributes['dob_2016']].compact

      if dates.length.zero?
        @attributes[:date_of_birth] = nil
      elsif dates.length == 1
        @attributes[:date_of_birth] = LsDate.parse_cmp_date(dates.first)&.to_s
      elsif dates.length == 2
        @attributes[:date_of_birth] = dates.map { |d| LsDate.parse_cmp_date(d)&.to_s }.compact.sort.last
      end
    end

    def add_alias(entity)
      fn = fetch('fullname')
      unless fn.present? && entity.also_known_as.map(&:downcase).include?(fn.downcase)
        entity.aliases.create!(name: fn)
      end
    end

    def to_person_hash
      {
        name_prefix: fetch('salutation'),
        name_first: fetch('firstname'),
        name_middle: fetch('middlename'),
        name_last: fetch('lastname'),
        name_suffix: fetch('suffix')
      }
    end
  end
end

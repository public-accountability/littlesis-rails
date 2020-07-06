# frozen_string_literal: true

class CongressImporter
  # Wrapper around the hash parsed from
  # the theunitedstates.io's yaml file
  class Legislator < SimpleDelegator
    attr_reader :entity

    def initialize(hash)
      super(hash)
      @types = fetch('terms').map { |t| t['type'] }.uniq
      @official_full_name = dig('name', 'official_full')
      @birthday = dig('bio', 'birthday')
      @gender = Person.gender_to_id(dig('bio', 'gender'))
      @website = fetch('terms').last.fetch('url', nil)
    end

    def representative?
      @types.include? 'rep'
    end

    def senator?
      @types.include? 'sen'
    end

    def terms_importer
      @terms_importer ||= CongressImporter::TermsImporter.new(self)
    end

    def legislator_matcher
      @legislator_matcher ||= CongressImporter::LegislatorMatcher.new(self)
    end

    def import!
      CongressImporter.transaction do
        if (@entity = legislator_matcher.entity)
          @entity.website = @website if @website
          @entity.start_date = @birthday if @birthday
          @entity.assign_attribute_unless_present(:blurb, generate_blurb)
          @entity.person.assign_attribute_unless_present(:name_middle, dig('name', 'middle'))
          @entity.person.gender_id = @gender
          if @entity.changed?
            @entity.last_user_id = CONGRESS_BOT_USER
            @entity.save!
          end

          if @official_full_name && !@entity.also_known_as.map(&:downcase).include?(@official_full_name.downcase)
            @entity.aliases.create!(name: @official_full_name)
          end

          @entity.add_extension('ElectedRepresentative')
          @entity.elected_representative.update!(elected_representative_attributes)
        else
          @entity = create_new_entity
        end
      end
    end

    private

    def entity_attributes
      LsHash.new(
        name: generate_name,
        primary_ext: 'Person',
        blurb: generate_blurb,
        website: @website,
        start_date: @birthday,
        last_user_id: CONGRESS_BOT_USER
      ).remove_nil_vals
    end

    def person_attributes
      LsHash.new(
        name_last: dig('name', 'last'),
        name_first: dig('name', 'first'),
        name_middle: dig('name', 'middle'),
        name_suffix: dig('name', 'suffix'),
        name_nick: dig('name', 'nick'),
        gender_id: @gender
      ).remove_nil_vals
    end

    def elected_representative_attributes
      LsHash.new(
        bioguide_id: dig('id', 'bioguide'),
        govtrack_id: dig('id', 'govtrack'),
        crp_id: dig('id', 'opensecrets'),
        fec_ids: dig('id', 'fec')
      ).remove_nil_vals
    end

    def create_new_entity
      entity = Entity.create!(entity_attributes)
      entity.person.update!(person_attributes)
      entity.add_extension('ElectedRepresentative', elected_representative_attributes)
      entity
    end

    def generate_name
      @official_full_name || "#{dig('name', 'first')} #{dig('name', 'last')}"
    end

    def generate_blurb
      term = fetch('terms').last
      rep_or_sen = term['type'] == 'sen' ? 'Senator' : 'Representative'
      state = AddressState.abbreviation_map.fetch(term['state'].upcase)

      "US #{rep_or_sen} from #{state}"
    rescue # rubocop:disable Style/RescueStandardError
      nil
    end
  end
end

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
        @entity = legislator_matcher.entity

        unless @entity.present?
          @entity = Entity.create!(name: generate_name,
                                   primary_ext: 'Person')
          @entity.person.update!(person_attributes)
        end

        @entity.website = @website if @website
        @entity.start_date = @birthday if @birthday
        @entity.assign_attribute_unless_present(:blurb, generate_blurb)
        @entity.person.assign_attribute_unless_present(:name_middle, dig('name', 'middle'))
        @entity.person.gender_id = @gender
        @entity.save!

        if @official_full_name && @entity.also_known_as.map(&:downcase).exclude?(@official_full_name.downcase)
          @entity.aliases.create!(name: @official_full_name)
        end

        @entity.add_extension('ElectedRepresentative')
        @entity.elected_representative.update!(elected_representative_attributes)

        fec_candidate_ids.each do |fec_id|
          @entity.external_links.fec_candidate.find_or_create_by!(link_id: fec_id)
        end
      end
    end

    private

    def fec_candidate_ids
      dig('id', 'fec') || []
    end

    def person_attributes
      with_indifferent_access_and_without_nil_values(
        name_last: dig('name', 'last'),
        name_first: dig('name', 'first'),
        name_middle: dig('name', 'middle'),
        name_suffix: dig('name', 'suffix'),
        name_nick: dig('name', 'nick'),
        gender_id: @gender
      )
    end

    def elected_representative_attributes
      with_indifferent_access_and_without_nil_values(
        bioguide_id: dig('id', 'bioguide'),
        govtrack_id: dig('id', 'govtrack'),
        crp_id: dig('id', 'opensecrets')
      )
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

    private

    def with_indifferent_access_and_without_nil_values(h)
      h.delete_if { |_k, v| v.nil? }.with_indifferent_access
    end
  end
end

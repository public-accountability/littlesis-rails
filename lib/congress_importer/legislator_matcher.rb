# frozen_string_literal: true

# This searches for matching LittleSis entity.
# It first looks for entities with matching bioguide or govtrack ids,
# which are stored on the ElectedRepresentative model.
# If no match is found by id, it uses EntityMatcher to search by name.
# The matched entity is stored on the attribute .entity
class CongressImporter
  class LegislatorMatcher
    attr_reader :entity, :matched_by_name

    # legistator = CongressImporter::Legislator
    def initialize(legislator)
      @legislator = legislator
      @matched_by_name = false
      @entity = nil

      bioguide_id = @legislator.dig('id', 'bioguide')
      govtrack_id = @legislator.dig('id', 'govtrack')
      fec_ids = @legislator.dig('id', 'fec')
      wikipedia = @legislator.dig('id', 'wikipedia')&.tr(' ', '_')

      if fec_ids.present?
        @entity = ExternalLink.find_by(link_type: :fec_candidate, link_id: fec_ids)&.entity
      end

      if bioguide_id && !@entity
        @entity = ElectedRepresentative.find_by(bioguide_id: bioguide_id)&.entity
      end

      if govtrack_id && !@entity
        @entity = ElectedRepresentative.find_by(govtrack_id: govtrack_id)&.entity
      end

      if wikipedia && !@entity
        @entity = ExternalLink.wikipedia.find_by(link_id: wikipedia)&.entity
      end

      if @entity.nil?
        @entity = match_by_name
        @matched_by_name = @entity.present?
      end

      freeze
    end

    private

    def match_by_name
      name_hash = @legislator
                    .fetch('name')
                    .slice('first', 'middle', 'last', 'suffix')
                    .transform_keys { |k| "name_#{k}" }

      associated = []
      associated << NotableEntities.fetch(:house_of_reps) if @legislator.representative?
      associated << NotableEntities.fetch(:senate) if @legislator.senator?

      EntityMatcher
        .find_matches_for_person(name_hash, associated: associated)
        .automatch
        &.entity
    end
  end
end

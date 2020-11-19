# frozen_string_literal: true

class ExternalEntity
  module Datasets
    module FECCandidate
      def matches
        raise NotImplementedError
      end

      def search_for_matches(search_term)
        raise NotImplementedError
      end

      def match_action
        ExternalLink
          .fec_candidate
          .find_or_create_by!(entity_id: entity.id, link_id: external_data.dataset_id)
      end

      def unmatch_action
        entity.external_links.fec_candidate.find_by(link_id: external_data.dataset_id).destroy!
      end

      def automatch
        return self if matched?

        if ExternalLink.fec_candidate.exists?(link_id: external_data.dataset_id)
          match_with ExternalLink.fec_candidate.find_by(link_id: external_data.dataset_id).entity
        end
      end

      # MAYBE TODO: implement this w/ EntityMatcher and automatically match?
      # def automatch_or_create
      # end

      def add_reference
        entity.add_reference(url: "https://www.fec.gov/data/candidate/#{external_data.dataset_id}/",
                             name: "fec.gov - candidate - #{external_data.dataset_id}/")
      end

      def set_primary_ext
        self.primary_ext = 'Person'
      end
    end
  end
end

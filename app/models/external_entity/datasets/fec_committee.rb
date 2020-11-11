# frozen_string_literal: true

class ExternalEntity
  module Datasets
    module FECCommittee
      def matches
        raise NotImplementedError
      end

      def search_for_matches(search_term)
        raise NotImplementedError
      end

      def match_action
        ExternalLink.fec_committee.find_or_create_by!(entity_id: entity.id, link_id: external_data.dataset_id)
      end

      def unmatch_action
        entity.external_links.fec_committee.find_by(link_id: external_data.dataset_id).destroy!
      end

      def automatch
        return self if matched?

        if ExternalLink.fec_committee.exists?(link_id: external_data.dataset_id)
          match_with ExternalLink.fec_committee.find_by(link_id: external_data.dataset_id).entity
        end
      end

      def add_reference
        entity.add_reference(url: "https://www.fec.gov/data/committee/#{external_data.dataset_id}/",
                             name: "fec.gov - committee - #{external_data.dataset_id}/")
      end

      def set_primary_ext
        self.primary_ext = 'Org'
      end
    end
  end
end

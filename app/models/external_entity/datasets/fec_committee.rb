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
        ExternalLink
          .fec_committee
          .find_or_create_by!(entity_id: entity.id, link_id: external_data.dataset_id)
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

      def automatch_or_create
        automatch
        return self if matched?

        committee_id = external_data.wrapper.committee_id
        committee_name = OrgName.format(external_data.wrapper.name)

        if committee_name.blank?
          Rails.logger.warn "cannot create Entity for FEC committee #{committee_id} because the committee name is blank"
          return self
        end

        Entity.transaction do
          Entity.create!(name: committee_name, primary_ext: 'Org').tap do |entity|
            entity.add_extension('PoliticalFundraising')
            entity.aliases.create!(name: committee_id)
            match_with(entity)
          end
        end
      end

      def add_reference
        entity.add_reference(
          url: "https://www.fec.gov/data/committee/#{external_data.dataset_id}/",
          name: "fec.gov - committee - #{external_data.dataset_id}/"
        )
      end

      def set_primary_ext
        self.primary_ext = 'Org'
      end
    end
  end
end

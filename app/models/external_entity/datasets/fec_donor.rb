# frozen_string_literal: true

class ExternalEntity
  module Datasets
    module FECDonor
      def matches
        EntityMatcher.find_matches_for_person(external_data.wrapper.name)
      end

      def search_for_matches(search_term)
        EntityMatcher.find_matches_for_person(search_term)
      end

      # When user clicks the "match" button on the fec match contributions page, this method gets called
      # This matches the associated External Relationship for all Individual Contributions connected to this donor.
            # external_entity-->external_data.fec_donor.data.sub_ids --> external_data.fec_contribution.dataset_id --> external_relationships
      def match_action
        ExternalData
          .includes(:external_relationships)
          .fec_contribution
          .where(dataset_id: external_data.wrapper.sub_ids)
          .map(&:external_relationships)
          .flatten
          .each { |er| er.match_entity1_with(entity) } # entity == ExternalEntity#entity
      end

      def unmatch_action
        ExternalData
          .includes(:external_relationships)
          .fec_contribution
          .where(dataset_id: external_data.wrapper.sub_ids)
          .map(&:external_relationships)
          .flatten
          .each do |er|

          if er.matched?
            Rails.logger.warn "Cannot unmatch external relationship #{er.id}"
          elsif er.entity1_id == entity.id
            er.update!(entity1_id: nil)
          end
        end
      end

      def automatch
        self
      end

      def add_reference; end

      def set_primary_ext; end
    end
  end
end

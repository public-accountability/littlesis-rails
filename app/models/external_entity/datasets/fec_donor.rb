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

      # After a user clicks the "match" button on the fec match contributions page,
      # it creates a match with ExternalEntity.fec_donor
      # This donor record contains sub_ids (external_data.wrapper.sub_ids) which are
      # links Individual Contributions records (which the donor dataset aggregates).
      # So this matches the associated External Relationship for all Individual Contributions
      # connected to this donor.
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

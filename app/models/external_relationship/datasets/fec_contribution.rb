# frozen_string_literal: true

class ExternalRelationship
  module Datasets
    # This connects to a row in fec.db, corresponding to an individual
    # transaction record in the FEC bulk data
    module FECContribution
      def relationship_attributes(is_new: false)
        if is_new
          {
            description1: 'Campaign Contribution',
            description2: 'Campaign Contribution',
            start_date: external_data.wrapper.date&.iso8601,
            end_date: external_data.wrapper.date&.iso8601,
            amount: external_data.wrapper.amount
          }
        else

          ed_contributions = ExternalData
                               .fec_contribution
                               .joins('external_relationships')
                               .where('external_relationships.entity1_id' => entity1_id)

          raise Exceptions::LittleSisError, "Could not find contributions" if ed_contributions.length.zero?

          {
            description1: 'Campaign Contribution',
            description2: 'Campaign Contribution',
            start_date: ed_contributions.map { |ed| ed.wrapper.date }.min&.iso8601,
            end_date: ed_contributions.map { |ed| ed.wrapper.date }.min&.iso8601,
            amount: ed_contributions.map { |ed| ed.wrapper.amount }.sum
          }
        end
      end

      def automatch
        cid = external_data.wrapper.committee_id
        entity = ExternalLink.fec_committee.find_by(link_id: cid).try(:entity)
        match_entity2_with(entity) if entity
      end

      def find_existing
        Relationship
          .where(attributes.slice('category_id', 'entity1_id', 'entity2_id'))
          .to_a
          .find { |r| r.description1 == 'Campaign Contribution' }
      end

      def potential_matches_entity1
        raise NotImplementedError
      end

      def potential_matches_entity2
        raise NotImplementedError
      end
    end
  end
end

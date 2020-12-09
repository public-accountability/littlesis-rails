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
            amount: external_data.wrapper.amount,
            filings: 1
          }
        else

          ed_contributions = ExternalData
                               .fec_contribution
                               .joins(:external_relationship)
                               .where('external_relationships.entity1_id' => entity1_id)
                               .where('external_relationships.entity2_id' => entity2_id)
                               .to_a

          if ed_contributions.length.zero?
            raise Exceptions::LittleSisError, 'Could not find contributions'
          end

          dates = ed_contributions.map { |ed| ed.wrapper.date }.delete_if(&:nil?)

          {
            description1: 'Campaign Contribution',
            description2: 'Campaign Contribution',
            start_date: dates.min&.iso8601,
            end_date: dates.max&.iso8601,
            amount: ed_contributions.map { |ed| ed.wrapper.amount }.sum,
            filings: ed_contributions.length
          }
        end
      end

      def automatch
        return if matched?

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

      def after_match_action
        ExternalData.services.synchronize_donor_candidate_relationship(self)
        if external_data.wrapper.image_number.present?
          relationship.add_reference(external_data.wrapper.document_attributes).save!
        end
      end

      alias synchronize_donor_candidate_relationship after_match_action

      def potential_matches_entity1
        raise NotImplementedError
      end

      def potential_matches_entity2
        raise NotImplementedError
      end

      def associated_fec_committee
        return @associated_fec_committee if defined?(@associated_fec_committee)

        @associated_fec_committee = ExternalData.fec_committee.find_by(dataset_id: external_data.wrapper.committee_id)
      end
    end
  end
end

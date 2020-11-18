# frozen_string_literal: true

class ExternalRelationship
  module Datasets
    # This connects to a row in fec.db, corresponding to an individual
    # transaction record in the FEC bulk data
    module FECContribution
      def relationship_attributes
        raise NotImplementedError
      end

      def automatch
        cid = external_data.wrapper.committee_id
        entity = ExternalLink.fec_committee.find_by(link_id: cid).try(:entity)
        match_entity2_with(entity) if entity
      end

      def find_existing
        raise NotImplementedError
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

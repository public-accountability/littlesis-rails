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
        raise NotImplementedError
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

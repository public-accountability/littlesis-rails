# frozen_string_literal: true

class ExternalRelationship
  module Datasets
    module Interface
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

      def after_match_action
      end
    end
  end
end

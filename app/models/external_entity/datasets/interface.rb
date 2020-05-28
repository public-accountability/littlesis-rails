# frozen_string_literal: true

class ExternalEntity
  module Datasets
    module Interface
      def matches
        raise NotImplementedError
      end

      def search_for_matches(search_term)
        raise NotImplementedError
      end

      def match_action
        raise NotImplementedError
      end

      def automatch
        self
      end

      def set_primary_ext
      end
    end
  end
end

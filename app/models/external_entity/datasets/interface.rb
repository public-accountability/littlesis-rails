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

      def unmatch_action
        Rails.logger.info "No unmatch action defined for #{dataset}"
      end

      def automatch
        self
      end

      def automatch_or_create
        raise NotImplementedError
      end

      def add_reference; end

      def set_primary_ext; end
    end
  end
end

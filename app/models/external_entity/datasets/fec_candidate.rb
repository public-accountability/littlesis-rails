# frozen_string_literal: true

class ExternalEntity
  module Datasets
    module FECCandidate
      def matches
        raise NotImplementedError
      end

      def search_for_matches(search_term)
        raise NotImplementedError
      end

      def match_action
        ExternalLink
          .fec_candidate
          .find_or_create_by!(entity_id: entity.id,
                              link_id:
                             )
      end

      def unmatch_action
        Rails.logger.info "No unmatch action defined for #{dataset}"
      end

      def automatch
        self
      end

      def add_reference; end

      def set_primary_ext; end
    end
  end
end

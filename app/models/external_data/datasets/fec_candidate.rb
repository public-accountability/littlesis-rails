# frozen_string_literal: true

class ExternalData
  module Datasets
    class FECCandidate < SimpleDelegator

      def candidate_fec_id
        self['']
      end

    end
  end
end

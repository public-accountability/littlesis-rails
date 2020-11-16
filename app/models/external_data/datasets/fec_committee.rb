# frozen_string_literal: true

class ExternalData
  module Datasets
    class FECCommittee < SimpleDelegator
      def name
        self['CMTE_NM']
      end
    end
  end
end

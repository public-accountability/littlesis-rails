# frozen_string_literal: true

class ExternalData
  module Datasets
    class NYCC < SimpleDelegator
      def self.search(params)
        ExternalData
          .nycc
          .where("JSON_VALUE(data, '$.FullName') like ?", params.query_string)
          .order(params.order_hash)
      end
    end
  end
end

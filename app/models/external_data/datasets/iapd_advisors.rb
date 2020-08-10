# frozen_string_literal: true

class ExternalData
  module Datasets
    class IapdAdvisors < SimpleDelegator
      def self.search(params)
        ExternalData
          .iapd_advisors
          .where("JSON_SEARCH(data, 'one', ?, null, '$.names') iS NOT NULL", params.query_string)
          .ordaer(params.order_hash)
      end
    end
  end
end

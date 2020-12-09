# frozen_string_literal: true

class ExternalData
  module Queries
    # [Int] --> [Hash]
    def self.aggregate_fec_contributions(sub_ids)
      @aggregator ||= proc do |cmte_id, arr|
        {
          # TODO: fix this sql n+1
          committee_name: ExternalData.fec_committee.find_by(dataset_id: cmte_id)&.wrapper&.name,
          committee_id: cmte_id,
          amount: arr.lazy.map(&:wrapper).map(&:amount).sum,
          count: arr.length,
          date_range: Datasets::FECContribution.calculate_date_range(arr)&.map(&:iso8601)
        }
      end

      ExternalData
        .fec_contribution
        .where(dataset_id: sub_ids)
        .to_a
        .group_by { |contribution| contribution.wrapper.committee_id }
        .map(&@aggregator)
    end
  end
end

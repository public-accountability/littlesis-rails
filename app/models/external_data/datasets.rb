# frozen_string_literal: true

class ExternalData
  module Datasets
    mattr_reader :names do
      ExternalData::DATASETS.keys.without(:reserved).map(&:to_s).freeze
    end

    mattr_reader :relationships do
      %w[iapd_schedule_a nys_disclosure].freeze
    end

    mattr_reader :entities do
      (names - relationships).freeze
    end

    mattr_reader :descriptions do
      {
        iapd_advisors: 'Investor Advisor corporations registered with the SEC',
        iapd_schedule_a: 'Owners and board members of investor advisors',
        nycc: 'New York City Council Members',
        nys_disclosure: 'New Yorak State Campaign Contributions',
        nys_filer: 'New York State Campaign Finance Committees',
        fec_candidate: 'Candidates for US Federal Office',
        fec_committee: 'Federal Campaign Finance Committees',
        fec_contribution: 'Federal Campaign Finance Individual Contributions',
        fec_donor: 'Donors extracted from FEC Individual Contributions'
      }.with_indifferent_access.freeze
    end

    mattr_reader :column_names do
      {
        nycc: %w[Name District Party],
        iapd_advisors: ['Name', 'Assets Under Management', 'CRD Number'],
        iapd_schedule_a: %w[Title Executive/Owner Advisor Acquired],
        nys_filer: %w[Name Type Office],
        nys_disclosure: %w[Disclosure Recipient Amount Date],
        fec_committee: ['Match', 'Name', 'Type', 'Address', 'Party', 'Connected Org'],
        fec_donor: %w[Name Location Employment Contributions]
      }
    end
  end
end

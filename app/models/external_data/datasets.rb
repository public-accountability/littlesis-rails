# frozen_string_literal: true

class ExternalData
  module Datasets
    mattr_reader :names, default: ExternalData::DATASETS.keys.without(:reserved).map(&:to_s).freeze
    mattr_reader :relationships, default: %w[iapd_schedule_a nys_disclosure].freeze
    mattr_reader :entities, default: (names - relationships).freeze
    mattr_reader :descriptions,
                 default: { iapd_advisors: 'Investor Advisor corporations registered with the SEC',
                            iapd_schedule_a: 'Owners and board members of investor advisors',
                            nycc: 'New York City Council Members',
                            nys_disclosure: 'New Yorak State Campaign Contributions',
                            nys_filer: 'New York State Campaign Finance Committees'
                          }.with_indifferent_access.freeze
  end
end

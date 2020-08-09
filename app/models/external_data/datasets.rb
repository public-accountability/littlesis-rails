# frozen_string_literal: true

class ExternalData
  module Datasets
    def self.relationships
      ['iapd_schedule_a', 'nys_disclosure'].freeze
    end

    def self.entities
      @entities ||= (names - relationships).freeze
    end

    def self.names
      @names ||= ExternalData::DATASETS.keys.without(:reserved).map(&:to_s).freeze
    end

    def self.inverted_names
      @inverted_names ||= names.invert.freeze
    end

    def self.descriptions
      @descriptions ||= {
        iapd_advisors: 'Investor Advisor corporations registered with the SEC',
        iapd_schedule_a: 'Owners and board members of investor advisors',
        nycc: 'New York City Council Members',
        nys_disclosure: 'New York State Campaign Contributions',
        nys_filer: 'New York State Campaign Finance Committees'
      }.with_indifferent_access.freeze
    end
  end
end

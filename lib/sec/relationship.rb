# frozen_string_literal: true

# rubocop:disable Layout/HashAlignment, Metrics/MethodLength

require 'csv'

module SEC
  module Relationship
    FIELDS = %i[owner owner_cik owner_url company company_cik company_url is_board is_executive start_date is_current].freeze

    def self.csv_headers
      CSV.generate_line(FIELDS)
    end

    def self.csv(relationship)
      CSV.generate_line hash(relationship).values_at(*FIELDS)
    end

    def self.json(relationship)
      JSON.pretty_generate hash(relationship)
    end

    def self.hash(relationship)
      {
        owner:            relationship.entity.name_with_id,
        owner_cik:        relationship.entity.external_links.sec_link_value,
        owner_url:        (relationship.entity.persisted? ? relationship.entity.url : nil),
        company:          relationship.related.name_with_id,
        company_cik:      relationship.related.external_links.sec_link_value,
        company_url:      (relationship.related.persisted? ? relationship.related.url : nil),
        is_board:         relationship.position.is_board,
        is_executive:     relationship.position.is_executive,
        start_date:       relationship.start_date,
        is_current:       relationship.is_current
      }
    end
  end
end

# rubocop:enable Layout/HashAlignment, Metrics/MethodLength

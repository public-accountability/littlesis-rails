# frozen_string_literal: true

# rubocop:disable Layout/AlignHash, Metrics/MethodLength

module Sec
  module Relationship
    def self.format(relationship)
      {
        owner:            relationship.entity.name_with_id,
        owner_cik:        relationship.entity.external_links.sec_link_value,
        onwer_url:        (relationship.entity.persisted? ? relationship.entity.url : nil),
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

# rubocop:enable Layout/AlignHash, Metrics/MethodLength

# frozen_string_literal: true

require 'csv'

module ExternalDataset
  class FECContribution < ApplicationRecord
    extend DatasetInterface
    extend FECData
    self.dataset = :fec_contributions
    # self.primary_key = 'sub_id'

    TRANSACTION_TYPES = Hash[*CSV.read(Rails.root.join('data/fec_transaction_types.csv')).flatten]
                          .transform_values(&:to_sym).freeze

    # Only search for these types
    PERMITTED_TRANSACTION_TYPES = %w[10 13 15 15C 15E 22Y].freeze

    belongs_to :fec_committee, ->(contribution) { where(fec_year: contribution.fec_year) },
               class_name: 'ExternalDataset::FECCommittee',
               foreign_key: 'cmte_id',
               primary_key: 'cmte_id'

    has_one :fec_match,
            foreign_key: 'sub_id',
            primary_key: 'sub_id',
            class_name: 'FECMatch',
            dependent: :restrict_with_exception,
            inverse_of: :fec_contribution

    def reference_url
      "https://docquery.fec.gov/cgi-bin/fecimg/?#{image_num}"
    end

    def reference_attributes
      { name: "FEC Filing #{image_num}", url: reference_url }
    end

    def as_presenter
      FECContributionPresenter.new(self)
    end

    unless Rails.env.test?
      def readonly?
        true
      end
    end

    def self.search_by_name(query)
      includes(:fec_match)
        .where(transaction_tp: PERMITTED_TRANSACTION_TYPES)
        .and(where("name_tsvector @@ websearch_to_tsquery(?)", query.upcase)
               .or(where(name: query.upcase)))
        .order(date: :desc)
    end
  end
end

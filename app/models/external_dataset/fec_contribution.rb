# frozen_string_literal: true

module ExternalDataset
  class FECContribution < ApplicationRecord
    extend DatasetInterface
    extend FECData
    self.dataset = :fec_contributions
    # self.primary_key = 'sub_id'

    belongs_to :fec_committee, ->(contribution) { where(fec_year: contribution.fec_year) },
               class_name: 'ExternalDataset::FECCommittee',
               foreign_key: 'cmte_id',
               primary_key: 'cmte_id'

    has_one :fec_match, foreign_key: 'sub_id', class_name: 'FECMatch', dependent: :restrict_with_exception, inverse_of: :fec_contribution

    def amount
      transaction_amt
    end

    def date
      if transaction_dt && /^\d{8}$/.match?(transaction_dt)
        Date.strptime(transaction_dt, '%m%d%Y')
      end
    end

    def reference_url
      "https://docquery.fec.gov/cgi-bin/fecimg/?#{image_num}"
    end

    def reference_attributes
      { name: "FEC Record \##{sub_id}", url: reference_url }
    end

    def location
      "#{city}, #{state}, #{zip_code}"
    end

    def employment
      "#{occupation} at #{employer}"
    end

    unless Rails.env.test?
      def readonly?
        true
      end
    end

    def self.search_by_name(query)
      includes(:fec_match).where("name_tsvector @@ websearch_to_tsquery(?)", query.upcase)
    end
  end
end

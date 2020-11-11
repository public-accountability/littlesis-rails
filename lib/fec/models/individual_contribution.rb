# frozen_string_literal: true

module FEC
  class IndividualContribution < ApplicationRecord
    self.primary_key = 'SUB_ID'
    # belongs_to :committee, foreign_key: 'CMTE_ID', class_name: 'Committee', inverse_of: :individual_contributions
    belongs_to :donor, optional: true, inverse_of: :individual_contributions

    attribute :AMNDT_IND, FEC::Types::AmendmentIndicator.new
    attribute :TRANSACTION_TP, FEC::Types::Transaction.new

    def amount
      self.TRANSACTION_AMT
    end

    def committee
      Committee.find_by(:FEC_YEAR => self.FEC_YEAR, :CMTE_ID => self.CMTE_ID)
    end

    def import_into_external_data
      unless ExternalData.fec_contribution.exists?(dataset_id: self.SUB_ID)
        ExternalData
          .fec_contribution
          .create!(dataset_id: self.SUB_ID, data: attributes)
          .external_relationship
          .fec_contribution
          .find_or_create_by!
      end
    end

    def self.large_transactions
      where arel_table[:TRANSACTION_AMT].gteq(1_000)
    end
  end
end

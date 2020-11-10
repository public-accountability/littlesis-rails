# frozen_string_literal: true

module FEC
  class DonorContribution < ApplicationRecord
    self.table_name = "donor_individual_contributions"
    self.primary_key = "individual_contribution_sub_id"

    belongs_to :donor
    belongs_to :individual_contribution, foreign_key: 'individual_contribution_sub_id'
  end
end

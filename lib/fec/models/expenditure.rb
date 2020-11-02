# frozen_string_literal: true

module FEC
  class Expenditure < ApplicationRecord
    default_scope { where(FEC_YEAR: 2020) }

    self.table_name = 'operating_expenditures'
    self.primary_key = 'SUB_ID'

    attribute :RPT_TP, FEC::Types::Report.new
  end
end

# frozen_string_literal: true

module FEC
  class Expenditure < ApplicationRecord
    self.table_name = 'operating_expenditures'
    self.primary_key = 'SUB_ID'

    belongs_to :committee, foreign_key: 'CMTE_ID', class_name: 'Committee' # , inverse_of: :contributions

    def amount
      attributes['TRANSACTION_AMT'].to_i
    end

    def name
      attributes['NAME']
    end

    def report_type
      FEC::Types::Report.parse attributes['RPT_TP']
    end

    def to_h
      {
        name: name,
        amount: attributes['TRANSACTION_AMT'].to_i,
        committee: committee.name_and_id
      }
    end

    def self.payments_to_google
      where 'NAME' => 'GOOGLE'
    end

    def self.top_clients(limit = 15)
      order('TRANSACTION_AMT', :desc)
        .limit(limit)
        .map(&:to_h)
    end
  end
end

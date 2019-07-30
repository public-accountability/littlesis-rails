# frozen_string_literal: true

module Sec
  class Roster < SimpleDelegator
    attr_reader :company

    def initialize(company)
      @company = company
      super(roster)
    end

    # Generates a hash where the key is the CIK of the owner and the value is an array
    # contains hashes with information from the  SEC filing
    def roster
      @company.self_filings.map(&:to_h).each_with_object(Hash.new { [] }) do |filing, obj|
        # a single filing can have multiple reporting owners
        filing[:reporting_owners].each do |owner|
          # add two fields from the filing
          owner_hash = owner.merge(filing.slice(:filename, :period_of_report))
          # add the hash to the array
          obj.store owner[:cik], obj[owner[:cik]] << owner_hash
          # sort array by period of report descending
          obj[owner[:cik]].sort! { |a, b| b[:period_of_report] <=> a[:period_of_report] }
        end
      end
    end

    # Outputs an array with tabular information from the filings
    # Uses the latest filing for most information such as "is_director"
    def spreadsheet
      to_h.map do |cik, filings|
        {
          cik: cik,
          name: filings.first.fetch(:name),
          document_count: filings.count,
          latest_filename: filings.first.fetch(:filename),
          latest_period_of_report: filings.first.fetch(:period_of_report),
          earliest_period_of_report: filings.last.fetch(:period_of_report),
          officer_title: filings.first.fetch(:officer_title),
          is_director: filings.first.fetch(:is_director),
          is_officer: filings.first.fetch(:is_officer),
          is_ten_percent: filings.first.fetch(:is_ten_percent)
        }
      end
    end
  end
end

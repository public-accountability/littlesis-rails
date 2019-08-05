# frozen_string_literal: true

module Sec
  class Roster
    attr_reader :company, :roster

    delegate_missing_to :@roster

    def initialize(company)
      @company = company
      @roster = generate_roster
    end

    # def reporting_owners
    #   @company
    #     .filings
    #     .select { |f| %w[3 4].include?(f.type) }
    #     .select { |f| f.document.issuer?(@company.cik) }
    #     .map { |f| f.document.reporting_owners }
    #     .flatten
    # end

    # Generates a hash where the key is the CIK of the owner and the value is an array
    # contains hashes with information from the  SEC filing
    def generate_roster
      @company
        .filings
        .select { |f| %w[3 4].include?(f.type) }
        .select { |f| f.document.issuer?(@company.cik) }
        .map    { |f| f.reporting_owners }
        .flatten
        .reduce(Hash.new { [] }) do |roster, reporting_owner|
          cik = reporting_owner.fetch(:cik)
          roster[cik] = roster[cik] << reporting_owner
          roster
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

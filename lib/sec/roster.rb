# frozen_string_literal: true

module Sec
  class Roster
    attr_reader :company, :roster

    delegate_missing_to :@roster

    def initialize(company)
      @company = company
      @roster = generate_roster
    end

    # Generates a hash where the key is the CIK of the owner and the value is an array
    # contains hashes with information from the  SEC filing
    def generate_roster
      roster_hash = Hash.new { [] }

      @company
        .filings
        .select { |f| %w[3 4].include?(f.type) }
        .select { |f| f.document.issuer?(@company.cik) }
        .each do |filing|
          filing.document.reporting_owners.each do |owner|
            owner_cik = owner.fetch('reportingOwnerId').fetch('rptOwnerCik')
            # add the metadata from the filing
            owner_hash = owner.merge('metadata' => filing.metadata.stringify_keys)
            # add the hash to the array
            roster_hash.store owner_cik, roster_hash[owner_cik] << owner_hash
          end
      end
      roster_hash
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

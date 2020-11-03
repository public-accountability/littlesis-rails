# frozen_string_literal: true

module SEC
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
      @company
        .filings
        .select { |f| %w[3 4].include?(f.type) }
        .each   { |f| f.download_and_save_data }
        .select { |f| f.document.issuer?(@company.cik) }
        .map(&:reporting_owners)
        .flatten
        .group_by { |owner| owner.fetch(:cik) }
        .transform_values! { |owners| owners.sort_by { |o| o.fetch('date_filed') }.reverse! }
    end

    # Outputs an array with tabular information from the filings
    # Uses the latest filing for most information such as "is_director"
    def spreadsheet
      to_h.map do |cik, reporting_owners|
        {
          cik: cik,
          name: reporting_owners.first.fetch(:name),
          document_count: reporting_owners.count,
          latest_filename: reporting_owners.first.fetch(:filename),
          latest_reporting_owners_date: reporting_owners.first.fetch(:date_filed),
          earliest_reporting_owners_date: reporting_owners.last.fetch(:date_filed),
          officer_title: reporting_owners.first.fetch(:officer_title),
          is_director: reporting_owners.first.fetch(:is_director),
          is_officer: reporting_owners.first.fetch(:is_officer),
          is_ten_percent: reporting_owners.first.fetch(:is_ten_percent_owner)
        }
      end
    end
  end
end

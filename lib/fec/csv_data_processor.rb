# frozen_string_literal: true

module FEC
  class CsvDataProcessor
    DONOR_CSV = File.join(FEC.configuration.fetch(:data_directory), 'donors.csv')
    DONOR_CONTRIBUTION_CSV = File.join(FEC.configuration.fetch(:data_directory), 'donor_individual_contributions.csv')

    def initialize
      @donor_id = 0
      run
    end

    def generate_donor_id
      @donor_id += 1
    end

    def with_csvs
      CSV.open(DONOR_CSV, 'w', col_sep: ',', quote_char: '"') do |donor_csv|
        CSV.open(DONOR_CONTRIBUTIONS_CSV, 'w', col_sep: ',', quote_char: '"') do |donor_contribution_csv|
          yield donor_csv, donor_contribution_csv
        end
      end
    end

    def run
      digests = {} # MD5(donor_name, city, state, zip_code, employer, occupation) => id

      FEC.logger.info "CREATING #{DONOR_CSV} and #{DONOR_CONTRIBUTION_CSV}"
      with_csvs do |donor_csv, donor_contribution_csv|
        IndividualContribution.large_transactions.find_each do |ic|
          next if ic.NAME.blank?

          donor_name = NameParser.format(ic.NAME)
          employer = OrgName.parse(ic.EMPLOYER).clean if ic.EMPLOYER.present?

          data = [donor_name, ic.CITY, ic.STATE, ic.ZIP_CODE, employer, ic.OCCUPATION]
          digest = Digest::MD5.digest(data.join(''))

          donor_id = if digests.key?(digest)
                       digests[digest]
                     else
                       generate_donor_id.tap do |id|
                         donor_csv << [id].concat(data) # save donor to donors.csv
                       end
                     end

          donor_contribution_csv << [donor_id, ic.SUB_ID]
        end
      end

      FEC::Database.execute <<~SQL
        .mode csv
        .import #{DONOR_CSV} donors
      SQL

      FEC::Database.execute <<~SQL
        .mode csv
        .import #{DONOR_CONTRIBUTIONS_CSV} donor_individual_contributions
      SQL
    end

    def self.run
      new
    end
  end
end

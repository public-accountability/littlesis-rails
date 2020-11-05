# frozen_string_literal: true

module FEC
  class CsvDataProcessor
    DONORS_CSV = File.join(FEC.configuration.fetch(:data_directory), 'donors.csv')
    DONOR_CONTRIBUTIONS_CSV = File.join(FEC.configuration.fetch(:data_directory), 'donor_individual_contributions.csv')

    def initialize
      @donor_id = Concurrent::AtonomicFixnum.new
      run
    end

    def with_csvs
      CSV.open(DONORS_CSV, 'w', col_sep: ',', quote_char: '"') do |donors_csv|
        CSV.open(DONOR_CONTRIBUTIONS_CSV, 'w', col_sep: ',', quote_char: '"') do |donor_contributions_csv|
          yield donors_csv, donor_contributions_csv
        end
      end
    end

    def run
      digests = Concurrent::Map.new
      # digests = {} # MD5(donor_name, city, state, zip_code, employer, occupation) => donor_id

      FEC.logger.info "CREATING #{DONORS_CSV} and #{DONOR_CONTRIBUTIONS_CSV}"

      with_csvs do |donors_csv, donor_contributions_csv|
        Parallel.each(IndividualContribution.find_in_batches) do |batch|
          batch.each do |ic|
            next if ic.NAME.blank?

            donor_name = NameParser.format(ic.NAME)
            employer = OrgName.parse(ic.EMPLOYER).clean if ic.EMPLOYER.present?

            data = [donor_name, ic.CITY, ic.STATE, ic.ZIP_CODE, employer, ic.OCCUPATION]
            digest = Digest::MD5.digest(data.join(''))

            unless digests.key?(digest) # Donor already exists
              digests.compute(digest) { @donor_id.increment }
              donors_csv << [digests.fetch(digest)].concat(data) # save donor to donors.csv
            end

            donor_contributions_csv << [digests.fetch(digest), ic.SUB_ID] # [donor_id, individual_contribution_sub_id]
          end
        end
      end

      FEC.logger.info "IMPORT: donors and donor_individual_contributions"

      FEC::Database.execute <<~SQL
          .mode csv
          .import #{DONORS_CSV} donors
        SQL

      FEC::Database.execute <<~SQL
          .mode csv
          .import #{DONOR_CONTRIBUTIONS_CSV} donor_individual_contributions
         SQL
    end
end

    def self.run
      new
    end
  end
end

# frozen_string_literal: true

module FEC
  class CsvDataProcessor
    BATCH_SIZE = 50_000
    DONORS_CSV = File.join(FEC.configuration.fetch(:data_directory), 'donors.csv')
    DONOR_CONTRIBUTIONS_CSV = File.join(FEC.configuration.fetch(:data_directory), 'donor_individual_contributions.csv')

    def initialize
      @donor_id = 0
      @digests = {}
      @total_count = IndividualContribution.count.to_f
      @current_count = 0
      FEC.logger.info "CREATING #{DONORS_CSV} and #{DONOR_CONTRIBUTIONS_CSV}"
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
      with_csvs do |donors_csv, donor_contributions_csv|
        IndividualContribution.find_in_batches(batch_size: BATCH_SIZE) do |batch|
          batch.each do |ic|
            next if ic.nil? || ic.NAME.blank?

            donor_name = NameParser.format(ic.NAME)
            employer = OrgName.parse(ic.EMPLOYER).clean if ic.EMPLOYER.present?

            data = [donor_name, ic.CITY, ic.STATE, ic.ZIP_CODE, employer, ic.OCCUPATION]
            digest = Digest::MD5.digest(data.join(''))

            unless @digests.key?(digest) # Donor already exists
              @digests.store(digest, @donor_id += 1)
              # @digests.compute(digest) { @donor_id += 1 }
              donors_csv << [@digests.fetch(digest)].concat(data) # save donor to donors.csv
            end

            donor_contributions_csv << [@digests.fetch(digest), ic.SUB_ID] # [donor_id, individual_contribution_sub_id]
          end

          FEC.logger.debug  "Individual contributions: #{ (@current_count / @total_count.to_f * 100).round(1) }% complete"
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

    def self.run
      new
    end
  end
end

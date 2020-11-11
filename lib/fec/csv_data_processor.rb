# frozen_string_literal: true

module FEC
  # Besides the tables generated directly from FEC data two
  # additional tables are created used to help LittleSis match donors.
  class CsvDataProcessor
    BATCH_SIZE = 50_000
    DONORS_CSV = File.join(FEC.configuration.fetch(:data_directory), 'donors.csv')
    DONOR_CONTRIBUTIONS_CSV = File.join(FEC.configuration.fetch(:data_directory), 'donor_individual_contributions.csv')

    def initialize
      @donor_id = 0
      @digests = {}  # MD5(name,city,state,zip_code,employer,occupation) ==> donor_id
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
          @current_count += batch.length

          batch.each do |ic|
            next if ic.nil? || ic.NAME.blank?

            donor_name = NameParser.format(ic.NAME)
            employer = OrgName.parse(ic.EMPLOYER).clean if ic.EMPLOYER.present?

            # A "Donor" is a unique combination of Name + City + State + Zip_code + Employer + Occupation
            data = [donor_name, ic.CITY, ic.STATE, ic.ZIP_CODE, employer, ic.OCCUPATION]
            digest = Digest::MD5.digest(data.join(''))

            unless @digests.key?(digest)
              @digests.store(digest, @donor_id += 1)
              donor_row = [@digests.fetch(digest)].concat(data)
              donors_csv << donor_row
            end

            donor_contributions_csv << [@digests.fetch(digest), ic.SUB_ID] # [donor_id, individual_contribution_sub_id]
          end

          FEC.logger.debug "Individual contributions: #{(@current_count / @total_count.to_f * 100).round(1)}% complete"
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

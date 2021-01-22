# frozen_string_literal: true

module ExternalDataset
  TABLE_PREFIX = 'external_data'
  ROOT_DIR = Rails.root.join('data/external_data')
  mattr_accessor :datasets

  self.datasets = {}

  module DatasetInterface
    # setup

    def dataset=(dataset)
      mattr_accessor :dataset_name
      self.dataset_name = dataset
      self.table_name = "#{TABLE_PREFIX}_#{dataset}"
      ExternalDataset.datasets[dataset] = self
    end

    # interface

    def download
      raise NotImplementedError
    end

    def extract
      raise NotImplementedError
    end

    def load
      raise NotImplementedError
    end

    def export
      raise NotImplementedError
    end

    def report
      puts "There are #{count} rows in #{table_name}"
    end

    # utility

    def run_query(sql)
      Rails.logger.info sql
      ApplicationRecord.connection.exec_query(Arel.sql(sql))
    end
  end

  class NYCC < ApplicationRecord
    extend DatasetInterface
    self.dataset = :nycc
    self.primary_key = :district

    @source_url = 'https://raw.githubusercontent.com/NewYorkCityCouncil/districts/master/district_data/council_members/members.json'
    @json_file = ROOT_DIR.join('original').join('nycc.json')
    @csv_file = ROOT_DIR.join('csv').join('nycc.csv')

    def self.download
      Utility.download_file(url: @source_url, path: @json_file)
    end

    def self.extract
      Utility.save_hash_array_to_csv(csv_file,
                                     JSON.parse(File.read(@json_file)).map do |x|
                                       {
                                         district: x['District'].to_i,
                                         personid: x['PersonId'].to_i,
                                         council_district: x['CouncilDistrict'],
                                         last_name: x['LastName'],
                                         first_name: x['FirstName'],
                                         full_name: x['FullName'],
                                         photo_url: x['PhotoURL'],
                                         twitter: x['TwitterHandle'],
                                         party: x['Party'],
                                         title: x['Title'],
                                         email: x['Email'],
                                         website: x['Website'],
                                         gender: x['Gender'],
                                         district_office: x['DistrictOfficeAddress'],
                                         legislative_office: x['LegislativeOfficeAddress']
                                       }
                                     end)
    end

    def self.load
      run_query "LOAD DATA LOCAL INFILE '#{@csv_file}'
                 REPLACE
                 INTO TABLE #{table_name}
                 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'
                 IGNORE 1 LINES
                 (#{File.open(csv_file, &:readline).chomp})"
    end
  end

  class NYSDisclosure < ApplicationRecord
    extend DatasetInterface
    self.dataset = :nys_disclosures

    @source_url = 'https://cfapp.elections.ny.gov/NYSBOE/download/ZipDataFiles/ALL_REPORTS.zip'
    @csv_file = ROOT_DIR.join('csv').join('nys_disclosures.csv')
    @zip_file = ROOT_DIR.join('original').join('ALL_REPORTS.zip')
    @columns = NYSDisclosureExtractor::HEADERS.dup.concat(['dataset_id']).freeze

    def self.download
      Utility.stream_file_if_not_exists(url: @source_url, path: @zip_file)
    end

    def self.extract
      CSV.open(@csv_file.to_s, 'w') do |csv_writer|
        NYSDisclosureExtractor.new(@zip_file).each do |row|
          csv_writer.puts row.values_at(*@columns)
        end
      end
    end

    def self.load
      run_query "LOAD DATA LOCAL INFILE '#{@csv_file}'
                 IGNORE
                 INTO TABLE #{table_name}
                 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'
                 (#{@columns.join(',')})"
    end
  end

  class NYSFfiler < ApplicationRecord
    extend DatasetInterface
    self.dataset = :nys_filers
    @source_url = 'https://cfapp.elections.ny.gov/NYSBOE/download/ZipDataFiles/commcand.zip'
    @csv_file = ROOT_DIR.join('csv').join('nys_filers.csv')
    @zip_file = ROOT_DIR.join('original').join('commcand.zip')
    @columns = %w[filer_id name filer_type status committee_type office district treas_first_name treas_last_name address city state zip].freeze

    def self.download
      Utility.stream_file_if_not_exists(url: @source_url, path: @zip_file)
    end

    def self.extract
      CSV.open(@csv_file, 'w') do |csv_writer|
        CommcandExtractor.each(@zip_file) do |row|
          csv_writer << row
        end
      end
    end

    def self.load
      run_query "LOAD DATA LOCAL INFILE '#{@csv_file}'
                 REPLACE
                 INTO TABLE #{table_name}
                 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'
                 (#{@columns.join(',')})"
    end
  end

  class FECCandidate < ApplicationRecord
    extend DatasetInterface
    self.dataset = :fec_candidates
  end

  class FECCommittee < ApplicationRecord
    extend DatasetInterface
    self.dataset = :fec_committees
  end

  class FECContribution < ApplicationRecord
    extend DatasetInterface
    self.dataset = :fec_contributions
  end

  datasets.each_key do |dataset|
    extend DatasetInterface
    define_singleton_method(dataset) { datasets[dataset] }
  end
end

# class IapdAdvisor < ApplicationRecord
#   extend DatasetInterface
#   self.dataset = :iapd_advisors
# end

# class IapdScheduleA < ApplicationRecord
#   extend DatasetInterface
#   self.dataset = :iapd_schedule_a
# end

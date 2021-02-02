# frozen_string_literal: true

module ExternalDataset
  TABLE_PREFIX = 'external_data'
  ROOT_DIR = Rails.root.join('data/external_data')
  mattr_accessor :datasets do
    {}
  end

  mattr_reader :descriptions do
    {
      iapd_advisors: 'Investor Advisor corporations registered with the SEC',
      iapd_schedule_a: 'Owners and board members of investor advisors',
      nycc: 'New York City Council Members',
      nys_disclosure: 'New Yorak State Campaign Contributions',
      nys_filer: 'New York State Campaign Finance Committees',
      fec_candidate: 'Candidates for US Federal Office',
      fec_committee: 'Federal Campaign Finance Committees',
      fec_contribution: 'Federal Campaign Finance Individual Contributions',
      fec_donor: 'Donors extracted from FEC Individual Contributions'
    }.with_indifferent_access.freeze
  end

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

    def description
      ExternalDataset.descriptions[dataset_name]
    end

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

  # Steps for a importing NYS Campaign Finance
  #   - go to publicreporting.elections.ny.gov download and all 4 ALL_REPORTS files
  #   - place those files in <Rails-root>/data/external_data/original/nys
  # 3. littlesis data extract nys_disclosures
  # 4. littlesis data extract nys_disclosures
  class NYSDisclosure < ApplicationRecord
    extend DatasetInterface
    self.dataset = :nys_disclosures

    @source_url = 'https://cfapp.elections.ny.gov/NYSBOE/download/ZipDataFiles/ALL_REPORTS.zip'
    @csv_file = ROOT_DIR.join('csv').join('nys_disclosures.csv')
    # @zip_file = ROOT_DIR.join('original').join('ALL_REPORTS.zip')
    # @columns = NYSDisclosureExtractor::HEADERS.dup.concat(['dataset_id']).freeze

    FILES = [
      %w[ALL_REPORTS_CountyCandidate COUNTY_CANDIDATE],
      %w[ALL_REPORTS_CountyCommittee COUNTY_COMMITTEE],
      %w[ALL_REPORTS_StateCandidate STATE_CANDIDATE],
      %w[ALL_REPORTS_StateCommittee STATE_COMMITTEE]
    ].freeze

    def self.download
      raise NotImplementedError, "this dataset requires manual downloading via a browser"
      # Utility.stream_file_if_not_exists(url: @source_url, path: @zip_file)
    end

    def self.extract
      FILES.each do |(outer, inner)|
        otherpath = ROOT_DIR.join('original/nys', "#{outer}.zip")
        innerpath = ROOT_DIR.join('original/nys', "#{inner}.zip")
        `unzip -o #{otherpath} #{inner}.zip -d #{ROOT_DIR.join('original/nys')}`
        `unzip -o #{innerpath} #{inner}.csv -d #{ROOT_DIR.join('original/nys')}`
      end
    end

    def self.load
      FILES.map(&:second).map { |x| ROOT_DIR.join('original/nys/', "#{x}.csv") }.each do |csv_file|
        run_query <<~SQL
          LOAD DATA LOCAL INFILE '#{csv_file}'
          IGNORE
          INTO TABLE #{table_name}
          FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'
        SQL
      end
    end
  end

  class NYSFfiler < ApplicationRecord
    extend DatasetInterface
    self.dataset = :nys_filers
    # This url stopped working in Janurary 2021
    # go to https://publicreporting.elections.ny.gov/DownloadCampaignFinanceData/DownloadCampaignFinanceData and use type filer_id
    @source_url = 'https://cfapp.elections.ny.gov/NYSBOE/download/ZipDataFiles/commcand.zip'
    @csv_file = ROOT_DIR.join('csv').join('nys_filers.csv')
    @zip_file = ROOT_DIR.join('original').join('commcand.zip')
    @columns = %w[filer_id filer_name compliance_type_desc filter_type_desc filter_status committee_type_desc office_desc district county_desc municipality_subdivision_desc treasurer_first_name treasurer_middle_name treasurer_last_name address city state zipcode].freeze

    def self.download
      raise NotImplementedError, "this dataset requires manual downloading via a browser"
      # Utility.stream_file_if_not_exists(url: @source_url, path: @zip_file)
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

  module FECData
    # use FEC::Cli to download and extract FEC data
    def load
      FECLoader.run(self)
    end
  end

  class FECCandidate < ApplicationRecord
    extend DatasetInterface
    extend FECData
    self.dataset = :fec_candidates
  end

  class FECCommittee < ApplicationRecord
    extend DatasetInterface
    extend FECData
    self.dataset = :fec_committees
  end

  class FECContribution < ApplicationRecord
    extend DatasetInterface
    extend FECData
    self.dataset = :fec_contributions
  end

  datasets.each_key do |dataset|
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

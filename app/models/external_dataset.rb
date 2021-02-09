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
      nys_disclosures: 'New Yorak State Campaign Contributions',
      nys_filers: 'New York State Campaign Finance Committees',
      fec_candidates: 'Candidates for US Federal Office',
      fec_committees: 'Federal Campaign Finance Committees',
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
      Utility.save_hash_array_to_csv(@csv_file,
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
                 (#{File.open(@csv_file, &:readline).chomp})"
    end
  end

  # Steps for a importing NYS Campaign Finance
  #   - go to publicreporting.elections.ny.gov download and all 4 ALL_REPORTS files
  #   - place those files in <Rails-root>/data/external_data/original/nys
  #   - littlesis data extract nys_disclosures
  #   - littlesis data load nys_disclosures
  class NYSDisclosure < ApplicationRecord
    extend DatasetInterface
    self.primary_key = 'trans_number'
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
      FileUtils.mkdir_p ROOT_DIR.join('csv/nys')

      FILES.each do |(outer, inner)|
        outer_zip = ROOT_DIR.join('original/nys', "#{outer}.zip")
        inner_zip = ROOT_DIR.join('original/nys', "#{inner}.zip")
        original_csv = ROOT_DIR.join('original/nys', "#{inner}.csv")
        output_csv = ROOT_DIR.join('csv/nys', "#{inner}.csv")
        system "unzip -o #{outer_zip} #{inner}.zip -d #{ROOT_DIR.join('original/nys')}", exception: true
        system "unzip -o #{inner_zip} #{inner}.csv -d #{ROOT_DIR.join('original/nys')}", exception: true
        system "tr -d '\\000' < #{original_csv} | iconv -f iso-8859-1 -t utf8  > #{output_csv}", exception: true
        system "csvclean #{output_csv}", exception: true, chdir: ROOT_DIR.join('csv/nys').to_s
      end
    end

    def self.load
      FILES.map(&:second).map { |x| ROOT_DIR.join('csv/nys', "#{x}_out.csv") }.each do |csv_file|
        run_query <<~SQL
          LOAD DATA LOCAL INFILE '#{csv_file}'
          IGNORE
          INTO TABLE #{table_name}
          FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'
          (filer_id, filer_previous_id, election_year, election_type, @dummy, filing_abbrev, filing_desc, r_amend, filing_cat_desc, filing_sched_abbrev, filing_sched_desc, loan_lib_number, trans_number, trans_mapping, sched_date, org_date, cntrbr_type_desc, cntrbn_type_desc, transfer_type_desc, receipt_type_desc, receipt_code_desc, purpose_code_desc, r_subcontractor, flng_ent_name, flng_ent_first_name, flng_ent_middle_name, flng_ent_last_name, flng_ent_add1, @dummy, flng_ent_city, flng_ent_state, flng_ent_zip, flng_ent_country, payment_type_desc, pay_number, owned_amt, org_amt, loan_other_desc, trans_explntn, r_itemized, r_liability, election_year_str, office_desc, district, dist_off_cand_bal_prop)
        SQL
      end
    end
  end

  class NYSFiler < ApplicationRecord
    extend DatasetInterface
    self.dataset = :nys_filers
    # This url stopped working in Janurary 2021
    # go to https://publicreporting.elections.ny.gov/DownloadCampaignFinanceData/DownloadCampaignFinanceData and use type filer_id
    @source_url = 'https://cfapp.elections.ny.gov/NYSBOE/download/ZipDataFiles/commcand.zip'
    @csv_file = ROOT_DIR.join('csv').join('nys_filers.csv')
    @zip_file = ROOT_DIR.join('original').join('commcand.zip')

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
                 (filer_id,filer_name,compliance_type_desc,filter_type_desc,filter_status,committee_type_desc,office_desc,district,county_desc,municipality_subdivision_desc,treasurer_first_name,treasurer_middle_name,treasurer_last_name,address,city,state,zipcode)"
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

    has_many :contributions,
             class_name: 'ExternalDataset::FECContribution',
             foreign_key: 'cmte_id',
             primary_key: 'cmte_id',
             inverse_of: :fec_committee

    def display_name
      "#{cmte_nm} (#{cmte_id})"
    end
  end

  class FECContribution < ApplicationRecord
    extend DatasetInterface
    extend FECData
    self.dataset = :fec_contributions

    belongs_to :fec_committee, ->(contribution) { where(fec_year: contribution.fec_year) },
               class_name: 'ExternalDataset::FECCommittee',
               foreign_key: 'cmte_id',
               primary_key: 'cmte_id'
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

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

    @csv_file = ROOT_DIR.join('csv').join('nys_disclosures.csv')

    def self.download
      raise NotImplementedError, "this dataset requires manual downloading via a browser"
    end

    def self.extract
      NYSDisclosureExtractor.run
    end

    def self.load
      run_query <<~SQL
        COPY #{table_name} (filer_id, filer_previous_id, cand_comm_name, election_year, election_type, county_desc, filing_abbrev, filing_desc, r_amend, filing_cat_desc, filing_sched_abbrev, filing_sched_desc, loan_lib_number, trans_number, trans_mapping, sched_date, org_date, cntrbr_type_desc, cntrbn_type_desc, transfer_type_desc, receipt_type_desc, receipt_code_desc, purpose_code_desc, r_subcontractor, flng_ent_name, flng_ent_first_name, flng_ent_middle_name, flng_ent_last_name, flng_ent_add1, flng_ent_city, flng_ent_state, flng_ent_zip, flng_ent_country, payment_type_desc, pay_number, owned_amt, org_amt, loan_other_desc, trans_explntn, r_itemized, r_liability, election_year_str, office_desc, district, dist_off_cand_bal_prop)
        FROM '/data/external_data/csv/nys/nys_disclosures.csv' WITH CSV;
      SQL
    end
  end

  class NYSFiler < ApplicationRecord
    extend DatasetInterface
    self.dataset = :nys_filers
    # This url stopped working in Janurary 2021
    # go to https://publicreporting.elections.ny.gov/DownloadCampaignFinanceData/DownloadCampaignFinanceData and use type filer_id
    @source_url = 'https://cfapp.elections.ny.gov/NYSBOE/download/ZipDataFiles/commcand.zip'
    @zip_file = ROOT_DIR.join('original/nys').join('commcand.zip')

    def self.download
      raise NotImplementedError, "this dataset requires manual downloading via a browser"
      # Utility.stream_file_if_not_exists(url: @source_url, path: @zip_file)
    end

    def self.extract
      FileUtils.mkdir_p ROOT_DIR.join('csv/nys')

      CSV.open(ROOT_DIR.join('csv/nys').join('nys_filers.csv').to_s, 'w') do |csv_writer|
        CommcandExtractor.each(@zip_file) do |row|
          csv_writer << row
        end
      end
    end

    def self.load
      run_query <<~SQL
        COPY #{table_name} (filer_id,filer_name,compliance_type_desc,filter_type_desc,filter_status,committee_type_desc,office_desc,district,county_desc,municipality_subdivision_desc,treasurer_first_name,treasurer_middle_name,treasurer_last_name,address,city,state,zipcode)
        FROM  '#{Pathname.new("/data").join("external_data/csv/nys/nys_filers.csv")}' WITH CSV;
      SQL
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

    belongs_to :candidate, ->(committee) { where(fec_year: committee.fec_year) },
               class_name: 'ExternalDataset::FECCandidate',
               foreign_key: 'cand_id',
               primary_key: 'cand_id',
               optional: true

    belongs_to :external_link,
               -> { where(link_type: :fec_committee) },
               class_name: 'ExternalLink',
               foreign_key: 'cmte_id',
               primary_key: 'link_id',
               optional: true

    has_one :entity, through: :external_link

    def display_name
      "#{cmte_nm} (#{cmte_id})"
    end

    def create_littlesis_entity
      return entity if entity.present?

      Entity.create!(primary_ext: 'Org', name: cmte_nm.titleize).tap do |entity|
        entity.add_extension('PoliticalFundraising')
        entity.external_links.create!(link_type: :fec_committee, link_id: cmte_id)
      end

      reload_entity
    end
  end

  class FECContribution < ApplicationRecord
    extend DatasetInterface
    extend FECData
    self.dataset = :fec_contributions
    # self.primary_key = 'sub_id'

    belongs_to :fec_committee, ->(contribution) { where(fec_year: contribution.fec_year) },
               class_name: 'ExternalDataset::FECCommittee',
               foreign_key: 'cmte_id',
               primary_key: 'cmte_id'

    has_one :fec_match, foreign_key: 'sub_id', class_name: 'FECMatch', dependent: :restrict_with_exception, inverse_of: :fec_contribution

    def amount
      transaction_amt
    end

    def date
      if transaction_dt && /^\d{8}$/.match?(transaction_dt)
        Date.strptime(transaction_dt, '%m%d%Y')
      end
    end

    def reference_url
      "https://docquery.fec.gov/cgi-bin/fecimg/?#{image_num}"
    end

    def reference_attributes
      { name: "FEC Record \##{sub_id}", url: reference_url }
    end

    def location
      "#{city}, #{state}, #{zip_code}"
    end

    def employment
      "#{occupation} at #{employer}"
    end

    def readonly?
      true
    end

    def self.search_by_name(query)
      includes(:fec_match).where("name_tsvector @@ websearch_to_tsquery(?)", query.upcase)
    end
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

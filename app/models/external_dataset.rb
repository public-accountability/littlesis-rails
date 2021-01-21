# frozen_string_literal: true

module ExternalDataset
  TABLE_PREFIX = 'external_data'
  ROOT_DIR = Rails.root.join('data/external_data')
  mattr_accessor :datasets
  self.datasets = {}

  class Base < ::ApplicationRecord
    self.abstract_class = true
    mattr_accessor :dataset_name, :source_url, :csv_file

    def self.dataset=(dataset)
      self.table_name = "#{TABLE_PREFIX}_#{dataset}"
      self.dataset_name = dataset
      ExternalDataset.datasets[dataset] = self
    end

    def self.run_query(sql)
      Rails.logger.info sql
      ApplicationRecord.connection.exec_query(Arel.sql(sql))
    end
  end

  class IapdAdvisor < Base
    self.dataset = :iapd_advisors
  end

  class IapdScheduleA < Base
    self.dataset = :iapd_schedule_a
  end

  class NYCC < Base
    self.dataset = :nycc
    self.primary_key = :district
    self.source_url = 'https://raw.githubusercontent.com/NewYorkCityCouncil/districts/master/district_data/council_members/members.json'
    self.csv_file = ROOT_DIR.join('csv').join('nycc.csv')

    def self.download
      Utility.download_file(url: source_url, path: ROOT_DIR.join('original').join('nycc.json'))
    end

    def self.extract
      Utility.save_hash_array_to_csv(csv_file,
                                     JSON.parse(File.read(ROOT_DIR.join('original').join('nycc.json'))).map do |x|
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
      run_query "LOAD DATA LOCAL INFILE '#{csv_file}'
                 REPLACE
                 INTO TABLE #{table_name}
                 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'
                 IGNORE 1 LINES
                 (#{File.open(csv_file, &:readline).chomp})"
    end
  end

  class NYSDisclosure < Base
   self.dataset = :nys_disclosures
  end

  class NYSFfiler < Base
    self.dataset = :nys_filers
  end

  class FECCandidate < Base
    self.dataset = :fec_candidates
  end

  class FECCommittee < Base
    self.dataset = :fec_committees
  end

  class FECContribution < Base
    self.dataset = :fec_contributions
  end

  datasets.each_key do |dataset|
    define_singleton_method(dataset) { datasets[dataset] }
  end
end

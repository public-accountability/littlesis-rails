# frozen_string_literal: true

module ExternalDataset
  class NYCC < ApplicationRecord
    extend DatasetInterface
    self.dataset = :nycc
    self.primary_key = :district

    @source_url = 'https://raw.githubusercontent.com/NewYorkCityCouncil/districts/master/district_data/council_members/members.json'
    @json_file = ROOT_DIR.join('original').join('nycc').join('nycc.json')
    @csv_file = ROOT_DIR.join('csv').join('nycc').join('nycc.csv')

    def self.download
      FileUtils.mkdir_p ROOT_DIR.join('original').join('nycc')
      Utility.download_file(url: @source_url, path: @json_file)
    end

    def self.transform
      FileUtils.mkdir_p ROOT_DIR.join('csv').join('nycc')
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
                                         district_office: x['DistrictOfficeAddress'].gsub("\n", " "),
                                         legislative_office: x['LegislativeOfficeAddress'].gsub("\n", " ")
                                       }
                                     end)
    end

    def self.load
      run_query <<~SQL
        COPY #{table_name} (#{File.open(@csv_file, &:readline).chomp})
        FROM '#{@csv_file.to_s.gsub("/littlesis", "")}' WITH CSV HEADER
      SQL
    end
  end
end

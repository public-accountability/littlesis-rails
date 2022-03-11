# frozen_string_literal: true

module ExternalDataset
  class NYSFiler < ApplicationRecord
    extend DatasetInterface
    self.dataset = :nys_filers
    # This url stopped working in Janurary 2021
    # @source_url = 'https://cfapp.elections.ny.gov/NYSBOE/download/ZipDataFiles/commcand.zip'
    # Instead go to https://publicreporting.elections.ny.gov/DownloadCampaignFinanceData/DownloadCampaignFinanceData and manually download the and Filter Data
    # then place this file, commcand.zip, in data/external_data/original/nys/commcand.zip
    # run littlesis data transform nys_filers
    # in production, move this file to the postgres server at /srv/nys_filers.csv
    # run littlesis data nys_filers
    @zip_file = ROOT_DIR.join('original/nys').join('commcand.zip')

    def self.download
      raise NotImplementedError, "this dataset requires manual downloading via a browser"
      # Utility.stream_file_if_not_exists(url: @source_url, path: @zip_file)
    end

    def self.transform
      FileUtils.mkdir_p ROOT_DIR.join('csv/nys')

      CSV.open(ROOT_DIR.join('csv/nys').join('nys_filers.csv').to_s, 'w') do |csv_writer|
        CommcandExtractor.each(@zip_file) do |row|
          csv_writer << row
        end
      end
    end

    def self.load
      directory = if Rails.env.production?
                    '/srv'
                  else
                    '/data/external_data/csv/nys'
                  end

      run_query <<~SQL
        COPY #{table_name} (filer_id,filer_name,compliance_type_desc,filter_type_desc,filter_status,committee_type_desc,office_desc,district,county_desc,municipality_subdivision_desc,treasurer_first_name,treasurer_middle_name,treasurer_last_name,address,city,state,zipcode)
        FROM  '#{directory}/nys_filers.csv' WITH CSV;
      SQL
    end
  end
end

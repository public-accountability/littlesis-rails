#!/usr/bin/env ruby
# frozen_string_literal: true

# Updates the ny_filer table with the latest data
# also see: lib/scripts/update-nys-campaign-finance-data

require Rails.root.join('lib', 'utility.rb').to_s
require Rails.root.join('lib', 'nys_campaign_finance.rb').to_s

URL =  'https://cfapp.elections.ny.gov/NYSBOE/download/ZipDataFiles/commcand.zip'
ZIP_FILE_PATH = Rails.root.join('data', 'commcand.zip').to_s
CSV_FILE_PATH = Rails.root.join('data', 'nys_filers.csv').to_s

if Utility.file_is_empty_or_nonexistent(ZIP_FILE_PATH) || !(File.ctime(ZIP_FILE_PATH).to_date === Time.current.to_date)
  ColorPrinter.print_blue "Downloading: #{URL}"
  Utility.stream_file url: URL, path: ZIP_FILE_PATH
else
  ColorPrinter.print_blue 'command.zip has already been downloaded'
end

ColorPrinter.print_blue "unzipping: #{ZIP_FILE_PATH}"

cmd = ['unzip', '-p', ZIP_FILE_PATH, 'COMMCAND.txt', '>', CSV_FILE_PATH].join(' ')
Utility.sh cmd, fail_message: "failed to unzip file #{ZIP_FILE_PATH}"

ColorPrinter.print_blue "Converting #{CSV_FILE_PATH} to UTF-8"
Utility.convert_file_to_utf8 CSV_FILE_PATH

ColorPrinter.print_blue 'Inserting new filers into the database'
NYSCampaignFinance.insert_new_filers CSV_FILE_PATH

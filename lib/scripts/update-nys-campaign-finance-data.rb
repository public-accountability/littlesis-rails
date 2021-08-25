#!/usr/bin/env ruby
# frozen_string_literal: true

# Performs all tasks required to upload NYS campaign finance data
# See also: lib/tasks/nys.rake and lib/nys_campaign_finance
#
# use: bin/rails runner ./lib/scripts/update-nys-campaign-finance-data
#
# rubocop:disable Style/ImplicitRuntimeError

URL = 'https://cfapp.elections.ny.gov/NYSBOE/download/ZipDataFiles/ALL_REPORTS.zip'

# Paths
ZIP_FILE_PATH = Rails.root.join('data', 'ALL_REPORTS.zip').to_s
CSV_FILE_PATH = Rails.root.join('data', 'nys_disclosures.csv').to_s
GOOD_DISCLOSURES = Rails.root.join('data', 'good_nys_disclosures.csv').to_s
BAD_DISCLOSURES = Rails.root.join('data', 'bad_nys_disclosures.csv').to_s

# Scripts
CLEAN_NY_DISCLOSURES = Rails.root.join('lib', 'scripts', 'clean_ny_disclosures').to_s
RAKE = Rails.root.join('bin', 'rake')

##
# helper functions

def sh(cmd, fail_message: nil)
  raise(fail_message || cmd) unless system(cmd)
end

##
# Download zip file from NYS Board of Elections
#

# Skip downloading the zip file if the local copy is less than 1 day old
if Utility.file_is_empty_or_nonexistent(ZIP_FILE_PATH) || !(File.ctime(ZIP_FILE_PATH).to_date === Time.current.to_date)
  ColorPrinter.print_blue "Downloading: #{URL}"
  Utility.stream_file url: URL, path: ZIP_FILE_PATH
else
  ColorPrinter.print_blue 'ALL_REPORTS.zip has already been downloaded'
end

##
# unzip the report
#

ColorPrinter.print_blue "unziping: #{ZIP_FILE_PATH}"
cmd = ['unzip', '-p', ZIP_FILE_PATH, 'ALL_REPORTS.out', '>', CSV_FILE_PATH].join(' ')
sh cmd, fail_message: "failed to unzip file #{ZIP_FILE_PATH}"

##
# convert file to UTF-8
#
ColorPrinter.print_blue "Converting #{CSV_FILE_PATH} to UTF-8"

Utility.convert_file_to_utf8(CSV_FILE_PATH)

##
# Clean disclosure data
#   - see lib/scripts/clean_ny_disclosures
#   - saves two files: good_nys_disclosures, bad_nys_disclosures
ColorPrinter.print_blue "Clean disclosure data #{CSV_FILE_PATH} to UTF-8"

cmd = ['cat', CSV_FILE_PATH, '|', CLEAN_NY_DISCLOSURES,
       "1> #{GOOD_DISCLOSURES}", "2> #{BAD_DISCLOSURES}"].join(' ')

sh cmd, fail_message: 'clean_ny_disclosures failed'

good_disclosures_count = `wc -l "#{GOOD_DISCLOSURES}"`.strip.split(' ')[0].to_i
bad_disclosures_count = `wc -l "#{BAD_DISCLOSURES}"`.strip.split(' ')[0].to_i

ColorPrinter.print_green "Good disclosures count: #{ActiveSupport::NumberHelper.number_to_human(good_disclosures_count)}"
ColorPrinter.print_red "Bad disclosures count: #{ActiveSupport::NumberHelper.number_to_human(bad_disclosures_count)}"

if bad_disclosures_count > 10_000
  raise 'Too many bad disclosures, aborting'
end

##
# Update database with new data

ColorPrinter.print_blue 'Uploading data to staging table'
sh "#{RAKE} nys:disclosure_import[#{GOOD_DISCLOSURES}]"

ColorPrinter.print_blue 'Removing all years except for 2019 & 2020 from staging table'
sh "#{RAKE} nys:limit_staging_to_years[2019,2020]"

ColorPrinter.print_blue 'Updating and inserting new dislcosures'
sh "#{RAKE} nys:disclosure_update"

# rubocop:enable Style/ImplicitRuntimeError

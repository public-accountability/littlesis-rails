# frozen_string_literal: true

# Assists in downloading SEC filings and parsing them.
# Unlike most of LittleSis's data this uses a sqlite3 database,
# which, by default, is located at /data/sec_filings.db.
#
# To create the initial database download the index files with command:
#   $ lib/scripts/sec_download_index
# This will produce a csv that starts with "sec_index"
#
# After create database with this command:
#   $ lib/scripts/sec_create_database
#
module Sec
  CIK_REGEX = /^[[:digit:]]{10}$/.freeze

  CIKS = {
    'GS' => '0000886982',
    'JPM' => '0000019617',
    'NFLX' => '0001065280'
  }.with_indifferent_access.freeze

  def self.verify_cik!(cik)
    raise InvalidCikNumber unless cik.present? && CIK_REGEX.match?(cik)
  end

  class InvalidCikNumber < StandardError; end
end

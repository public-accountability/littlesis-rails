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
# The database that's built contains two tables with the following structure:
#
#  filings (
#      cik TEXT,
#      company_name TEXT,
#      form_type TEXT,
#      date_filed DATE,
#      filename TEXT
#   )
#  
# documents (
#     filename TEXT UNIQUE,
#     data TEXT
# )
#
# In the object initialization of Sec::Filings, if the data is missing from the documents table, an HTTP request is sent to sec.gov to retrieve the document (an XML file) and save it to the database.
#
# 
module Sec
  CIK_REGEX = /^[[:digit:]]{10}$/.freeze

  # A mapping between tickers and CIKs,
  # and, helped by a gratuitous use of `tap` and `defined_singleton_method`,
  # an easy way to get an examples instance of Sec::Company.
  #
  # Example:
  #   Sec::CIK.JPM --> Sec::Company instance for JP. Morgan Chase.
  #
  # it's useful for debugging and exploring the data in the terminal.
  CIKS = {
    'GS' => '0000886982',
    'JPM' => '0000019617',
    'NFLX' => '0001065280',
    'EEP' => '0000880285',
    'AMZN' => '0001018724'
  }.tap do |h|
    h.keys.each do |ticker|
      h.define_singleton_method(ticker) do
        Sec.database.company(h[ticker])
      end
    end
  end.freeze

  def self.database(*args)
    @database ||= Sec::FilingsDb.new(*args)
  end

  def self.verify_cik!(cik)
    raise InvalidCikNumber unless cik.present? && CIK_REGEX.match?(cik)
  end

  class InvalidCikNumber < StandardError; end
end

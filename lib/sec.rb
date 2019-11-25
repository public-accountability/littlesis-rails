# frozen_string_literal: true

# Downloads SEC filings and parses them.
# Unlike most of LittleSis's data this uses a sqlite3 database,
# which, by default, is located at /data/sec_filings.db.
#
# To create the initial database download the index files with command:
#   $ lib/scripts/sec_download_index
# This will produce a csv that starts with "sec_index"
#
# Then create database with this command:
#   $ lib/scripts/sec_create_database [path/to/sec_index.csv]
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
# If the data is missing from the documents table, Sec:Filing
# can retrieve the document (an XML file) from sec.gov and save
# it to the database.
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
    @database ||= Sec::Database.new(*args)
  end

  def self.verify_cik!(cik)
    raise InvalidCikNumber unless cik.present? && CIK_REGEX.match?(cik)
  end

  def self.top_companies(n = 100)
    Entity
      .select('entity.*', "LPAD(external_links.link_id, 10, '0') as cik")
      .joins(:external_links)
      .where('external_links.link_type' => ExternalLink::LINK_TYPES.dig(:sec, :enum_val))
      .where(primary_ext: 'Org')
      .order('entity.link_count DESC')
      .limit(n)
  end

  class InvalidCikNumber < StandardError; end
end

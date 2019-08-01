# frozen_string_literal: true

require 'sqlite3'

module Sec
  class Database
    extend Forwardable
    attr_reader :db

    def_delegators :@db, :execute, :close

    DEFAULT_PATH = Rails.root.join('data', 'sec_filings.db').to_s

    DEFAULT_FORMS = ['3', '4', '5', '8-K', 'SC 13G',
                     'SC 13G/A', '424B2', 'D', '497K',
                     '6-K', '10-Q', '497'].freeze

    def initialize(options = {})
      @path = options.fetch(:path, DEFAULT_PATH)
      @forms = options.fetch(:forms, DEFAULT_FORMS)
      @readonly = options.fetch(:readonly, false)
      @db = SQLite3::Database.new(
        @path,
        { readonly: @readonly, results_as_hash: true }
      )
    end

    # output: [SQLite3::ResultSet::HashWithTypesAndFields]
    # queries the database to query filings
    # cik --> selects by cik number
    # form_types ---> is a list of forms types to query for
    # limit/offset --> passed to sql
    #
    # Example hash:
    #   {"cik" => "4962",
    #    "company_name" => "AMERICAN EXPRESS CO",
    #    "form_type" => "10-Q",
    #    "date_filed" => "2019-07-23",
    #    "filename" => "edgar/data/4962/0000004962-19-000051.txt",
    #    "data" => nil}
    #
    #  "data" is from the documents table and, if present, contains the document
    #  The rest of the fields are called "metadata" by Sec::Filing
    def forms(cik: nil, form_types: nil, limit: 20, offset: 0)
      form_types_sql = case form_types
                       when Array
                         "form_type IN #{ApplicationRecord.sqlize_array(form_types)}"
                       when String
                         "form_type IN #{ApplicationRecord.sqlize_array([form_types])}"
                       else
                         "form_type IN #{ApplicationRecord.sqlize_array(@forms)}"
                       end

      cik_sql = cik.present? ? "cik = '#{cik.sub(/^0+/, '')}'" : '1'

      execute <<-SQL
        SELECT filings.*,
               documents.data
        FROM filings
        LEFT JOIN documents on documents.filename = filings.filename
        WHERE #{cik_sql} AND #{form_types_sql}
        ORDER BY date_filed DESC
        LIMIT #{limit} OFFSET #{offset}
      SQL
    end

    # input: string (cik)
    # output: [Sec::Filing]
    def filings_for(cik)
      Sec.verify_cik! cik

      forms(cik: cik, limit: 10_000).map do |row|
        Filing.new(data: row.delete('data'),
                   metadata: row,
                   db: self)
      end
    end

    def fetch_document(filename)
      execute("SELECT data from documents WHERE filename = ?", [filename])
        &.first&.first
    end

    def insert_document(filename:, data:)
      execute("INSERT INTO documents (filename, data) VALUES(?, ?)", [filename, data])
    end

    # convenience method for:
    #   Sec::Company.new(cik, db: db)
    def company(cik)
      Sec::Company.new(cik, db: self)
    end

    # Class Methods #

    def self.print(rows, sep: "\t", fields: nil)
      headers = fields.present? ? fields : rows.first.keys
      
      puts headers.join(sep)

      rows.each do |r|
        puts r.to_h.symbolize_keys.values_at(*headers).join(sep)
      end
    end
  end
end

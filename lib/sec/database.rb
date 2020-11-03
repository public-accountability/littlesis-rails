# frozen_string_literal: true

require 'sqlite3'

module SEC
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
      @db = SQLite3::Database.new @path, readonly: @readonly, results_as_hash: true
    end

    # output: [SQLite3::ResultSet::HashWithTypesAndFields]
    # queries the SEC sqlite database for forms
    #
    # cik               selects by cik number
    # form_types        list of forms types to limit search to
    # limit/offset      values passed to sql. defaults: 20/0
    #
    # Example resulting hash:
    #   {"cik" => "4962",
    #    "company_name" => "AMERICAN EXPRESS CO",
    #    "form_type" => "10-Q",
    #    "date_filed" => "2019-07-23",
    #    "filename" => "edgar/data/4962/0000004962-19-000051.txt",
    #    "data" => nil}
    #
    #  "data" is from the documents table and, if present, contains the document (usually HTML or XML).
    #  The rest of the fields are considered "metadata" by Sec::Filing
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
    def filings_for(cik, **kwargs)
      Sec.verify_cik! cik

      forms(cik: cik, limit: 10_000, **kwargs).map do |row|
        Filing.new(data: row.delete('data'),
                   metadata: row,
                   db: self)
      end
    end

    def fetch_document(filename)
      execute('SELECT data from documents WHERE filename = ?', [filename])
        &.first&.first
    end

    def insert_document(filename:, data:)
      execute('INSERT INTO documents (filename, data) VALUES(?, ?)', [filename, data])
    end

    # convenience method for:
    #   Sec::Company.new(cik, db: db)
    def company(cik)
      Sec::Company.new(cik, db: self)
    end
  end
end

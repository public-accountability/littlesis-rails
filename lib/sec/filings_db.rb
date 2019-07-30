# frozen_string_literal: true

require 'sqlite3'

module Sec
  class FilingsDb
    extend Forwardable
    attr_reader :db

    def_delegators :@db, :execute, :close

    DEFAULTS = {
      database: Rails.root.join('data', 'sec_filings.db').to_s,
      forms: %w[3 4],
      readonly: false
    }.freeze

    def initialize(options = {})
      @options = DEFAULTS.merge(options)
      @db = SQLite3::Database.new(
        @options[:database],
        @options.slice(:readonly).merge(results_as_hash: true)
      )
    end

    def filings_for(cik)
      execute <<-SQL
        SELECT filings.*,
               documents.data
        FROM filings
        LEFT JOIN documents on documents.filename = filings.filename
        WHERE cik = '#{cik.sub(/^0+/, '')}'
          AND form_type IN #{ApplicationRecord.sqlize_array(@options.fetch(:forms))}
        ORDER BY date_filed DESC
      SQL
    end

    def fetch_document(filename)
      db.execute("SELECT data from documents WHERE filename = ?", [filename])
        &.first&.first
    end

    def insert_document(filename:, data:)
      db.execute("INSERT INTO documents (filename, data) VALUES(?, ?)", [filename, data])
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

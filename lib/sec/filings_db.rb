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
      @db = SQLite3::Database.new(@options[:database],
                                  @options.slice(:readonly))
    end

    def filings_for(cik)
      execute <<-SQL
        SELECT form_type, date_filed, filename
        FROM filings
        WHERE cik = '#{cik.sub(/^0+/, '')}'
          AND form_type IN #{ApplicationRecord.sqlize_array(@options.fetch(:forms))}
        ORDER BY date_filed DESC
      SQL
    end


    # Class Methods #

    def self.print(rows, headers, sep: "\t")
      puts headers.join(sep)
      rows.each { |r| puts r.join(sep) }
    end
  end
end

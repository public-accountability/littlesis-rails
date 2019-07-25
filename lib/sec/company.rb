# frozen_string_literal: true

module Sec
  class Company
    attr_reader :cik

    def initialize(cik, db: nil)
      Sec.verify_cik! cik
      @cik = cik
      @db = db if db.present?
    end

    def filings
      return @filings if defined?(@filings)

      @filings = db.filings_for(@cik).map do |row|
        Filing.new(form_type: row[0],
                   date_filed: row[1],
                   filename: row[2],
                   data: row[3],
                   cik: @cik,
                   db: db)
      end
    end

    def db
      @db ||= FilingsDb.new
    end

    def roster
    end
  end
end

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
        Filing.new row.symbolize_keys.merge(db: db)
      end
    end

    def roster
      @roster ||= Sec::Roster.new(self)
    end

    def db
      @db ||= FilingsDb.new
    end

  end
end

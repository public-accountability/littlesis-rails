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

      @filings = db.filings_for(@cik)
    end

    def roster
      @roster ||= Sec::Roster.new(self)
    end

    # # without this `select`, #filings will also include
    # # documents where the company is reporting owner and
    # # not the issuer.
    # def self_filings
    #   filings
    #     .select { |f| f.to_h.dig(:issuer, :cik) == @cik }
    # end

    # def form4s
    #   db.filings_for(@cik)
    #   filings.select { |f| f.form_type == '4' }
    # end

    # def roster
    #   @roster ||= Sec::Roster.new(self)
    # end

    def db
      @db ||= FilingsDb.new
    end
  end
end

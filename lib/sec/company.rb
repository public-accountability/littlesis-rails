# frozen_string_literal: true

module SEC
  class Company
    attr_reader :cik

    def initialize(cik, db: nil)
      Sec.verify_cik! cik
      @cik = cik
      @database = db if db.present?
    end

    def filings
      return @filings if defined?(@filings)

      @filings = database.filings_for(@cik)
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

    def database
      @database ||= Sec.database
    end
  end
end

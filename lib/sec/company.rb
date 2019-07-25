# frozen_string_literal: true

module Sec
  class Company
    attr_reader :cik

    def initialize(cik)
      Sec.verify_cik! cik
      @cik = cik
    end

    def filings
      return @filings if defined?(@filings)

      @filings = FilingsDb.new.filings_for(@cik)
    end
  end
end

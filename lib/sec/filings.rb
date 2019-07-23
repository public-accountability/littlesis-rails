# frozen_string_literal: true

module Sec
  module Filings
    BROWSE_EDGAR_URL = 'http://www.sec.gov/cgi-bin/browse-edgar'

    def self.get_xml(cik, start: 0, count: 100)
      params = { 'action' => 'getcompany',
                 'output' => 'xml',
                 'start' => start,
                 'count' => count,
                 'CIK' => cik }

      HTTParty.get(BROWSE_EDGAR_URL, query: params).body
    end
  end
end

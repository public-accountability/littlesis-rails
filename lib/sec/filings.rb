# frozen_string_literal: true

module Sec
  module Filings
    BROWSE_EDGAR_URL = 'http://www.sec.gov/cgi-bin/browse-edgar'

    Filing = Struct.new(:date, :href, :form_name, :type, :text_href, keyword_init: true)

    # input: String (CIK number)
    # output: String (XML)
    # Performs GET request to EDGAR and returns the XML
    # of the listing of filings
    def self.get_xml(cik, start: 0, count: 100)
      params = { 'action' => 'getcompany',
                 'output' => 'xml',
                 'start' => start,
                 'count' => count,
                 'CIK' => cik }

      HTTParty.get(BROWSE_EDGAR_URL, query: params).body
    end

    # input: String (XML)
    # output: [Filing]
    def self.parse_filings_xml(xml)
      Nokogiri::XML(xml).at('companyFilings').at('results').search('filing').map do |filing|
        Filing.new(date: filing.at('dateFiled').text,
                   href: filing.at('filingHREF').text,
                   form_name: filing.at('formName').text,
                   type: filing.at('type').text)
      end
    end
  end
end

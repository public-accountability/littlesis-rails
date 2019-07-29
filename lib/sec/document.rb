# frozen_string_literal: true

module Sec
  # This class handles the parsing of the document data (xml)
  class Document
    attr_reader :form_type, :data, :xml, :hash

    delegate :to_h, :to_hash, :to_json, :as_json, to: :@hash

    def initialize(form_type:, data:)
      @form_type = form_type
      @data = data
      @xml = Nokogiri::XML(@data)
      reporting_owner_check!

      @hash = case @form_type
              when '4'
                parse_4
              else
                raise ArgumentError, "Cannot parse form type #{@form_type}"
              end

      @hash.freeze
      freeze
    end

    private

    def parse_4
      {
        period_of_report: extract('periodOfReport'),
        issuer_cik: extract('issuerCik'),
        issuer_name: extract('issuerName'),
        issuer_trading_symbol: extract('issuerTradingSymbol'),
        owner_cik: extract('rptOwnerCik'),
        owner_name: extract('rptOwnerName'),
        owner_is_director: extract('isDirector', :boolean),
        owner_is_officer: extract('isOfficer', :boolean),
        owner_is_ten_percent: extract('isTenPercentOwner', :boolean),
        owner_is_other: extract('isOther', :boolean),
        owner_officer_title: extract('officerTitle'),
        owner_signature_name: extract('signatureName'),
        owner_signature_date: extract('signatureDate')
      }
    end

    def extract(element_name, converter = nil)
      val = @xml.at(element_name).text.strip

      if converter == :boolean
        val == '1'
      else
        val
      end
    end

    # Verifies that the xml contains only one reporting one reporting one
    def reporting_owner_check!
      count = @xml.search('reportingOwner').size

      raise ArgumentError, 'no <reportingOwner> element found' if count.zero?
      raise ArgumentError, 'more than one <reportingOwner> elements found' if count > 1
    end
  end
end

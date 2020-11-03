# frozen_string_literal: true

module SEC
  # Document attributes
  #
  # data --> string of entire SEC EDGAR document
  # text --> string of sub-document without the edgar header information. Should be HTML or XML.
  # document --> Nokogiri::HTML::Document or Nokogiri::XML::Document
  # hash --> parsed document (will only exist for XML)
  class Document
    attr_accessor :data, :text, :document, :hash
    delegate_missing_to :@hash

    XML_REGEX = /<(?:xml|XML)>(.+)<\/(?:xml|XML)>/m
    HTML_REGEX = /<(?:html|HTML)>(.+)<\/(?:html|HTML)>/m

    def initialize(data)
      # These text documents look a lot like XML, but they are actually SGML
      # There isn't a good parsing solution for them in ruby, but
      # the SGML is mostly a wrapper for a file, typically XML or HTML.
      @data = data

      if XML_REGEX.match?(data)
        @text = XML_REGEX.match(data)[1]
        @document = Nokogiri::XML(@text)
        @hash = Hash.from_xml(@text).freeze
      elsif HTML_REGEX.match?(data)
        @text = HTML_REGEX.match(data)[1]
        @document = Nokogiri::HTML(@text)
        # right now we don't parse edgar documents that contain HTML
        # document.hash =
      else
        raise InvalidDocumentError
      end
      freeze
    end

    # helper methods to extract information. Only works on Form 3s and Form 4s

    def issuer?(cik)
      SEC.verify_cik! cik

      issuer.fetch('issuerCik') == cik
    end

    # --> [SEC::ReportingOwner]
    def reporting_owners
      Array
        .wrap(dig('ownershipDocument', 'reportingOwner'))
        .map { |owner| ReportingOwner.new(owner) }
    end

    def issuer
      dig 'ownershipDocument', 'issuer'
    end

    def type
      dig 'ownershipDocument', 'documentType'
    end

    def period_of_report
      dig 'ownershipDocument', 'periodOfReport'
    end

    class InvalidDocumentError < StandardError; end
  end
end

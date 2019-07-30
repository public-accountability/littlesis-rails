# frozen_string_literal: true

module Sec
  class Document < Hash
    def self.create(data)
      # Double XML alert!
      # Each SEC document is an XML document that has another
      # xml document inside of it under tagged named "XML"
      document_xml = Nokogiri::XML(data).at('XML').children.to_s
      new.replace(Hash.from_xml(document_xml)).freeze
    end

    # a few helper methods to extract information

    def issuer
      dig 'ownershipDocument', 'issuer'
    end

    def type
      dig 'ownershipDocument', 'documentType'
    end

    def period_of_report
      dig 'ownershipDocument', 'periodOfReport'
    end
  end
end

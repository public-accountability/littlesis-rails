# frozen_string_literal: true

module Sec
  # SEC forms 3,4,5 are all changes in "beneficial ownership"
  # intended to discourage insider trading.
  # 
  class BeneficialOwnershipForm

    # def self.create_from_filing(filing)
    #   TypeCheck.check filing, Sec::Filing

    #   new(filing.data
    # end
    
    attr_reader :data, :xml, :hash

    delegate_missing_to :@hash

    # Data is an XML string
    def initialize(data)
      @data = data
      @xml = Nokogiri::XML(@data)
      check_document!
      @hash = parse.freeze
      freeze
    end

    private

    def parse
      {
        period_of_report: extract('periodOfReport'),
        form_type: extract('documentType'),
        issuer: issuer,
        reporting_owners: reporting_owners,
        signatures: signatures
      }
    end

    def reporting_owners
      @xml.search('reportingOwner').map do |owner|
        {
          cik: extract('rptOwnerCik', root: owner),
          name: extract('rptOwnerName', root: owner),
          is_director: extract('isDirector', root: owner, converter: :boolean),
          is_officer: extract('isOfficer', root: owner, converter: :boolean),
          is_ten_percent: extract('isTenPercentOwner', root: owner, converter: :boolean),
          is_other: extract('isOther', root: owner, converter: :boolean),
          officer_title: extract('officerTitle', root: owner)
        }
      end
    end

    def signatures
      @xml.search('ownerSignature').map do |signature|
        {
          name: extract('signatureName', root: signature),
          date: extract('signatureDate', root: signature)
        }
      end
    end

    def issuer
      {
        cik: extract('issuer/issuerCik'),
        name: extract('issuer/issuerName'),
        trading_symbol: extract('issuer/issuerTradingSymbol')
      }
    end

    def check_document!
      if @xml.search('issuer').size != 1
        raise ArgumentError, "Document does not contain a single issuer"
      end
    end

    def extract(element_name, root: nil, converter: nil)
      val = (root || @xml).at(element_name)&.text&.strip

      return nil if val.nil?

      if converter == :boolean
        %w[t true yes y 1].include? val.downcase
      else
        val
      end
    end
  end
end

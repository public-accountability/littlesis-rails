describe Sec do
  # The test database was built from this sample csv:
  #
  # 886982,GOLDMAN SACHS GROUP INC,4,2014-02-03,edgar/data/886982/0000769993-14-000084.txt
  # 886982,GOLDMAN SACHS GROUP INC,4,2014-02-05,edgar/data/886982/0000769993-14-000090.txt
  # 886982,GOLDMAN SACHS GROUP INC,3,2014-08-06,edgar/data/886982/0001104659-14-057760.txt
  # 1065280,NETFLIX INC,4,2014-10-03,edgar/data/1065280/0001082906-14-000050.txt
  # 34088,EXXON MOBIL CORP,8-K,2019-07-01,edgar/data/34088/0000034088-19-000032.txt
  # 895421,MORGAN STANLEY,SC 13G,2019-07-08,edgar/data/895421/0000895421-19-000513.txt
  let(:test_db_path) do
    Rails.root.join('spec', 'testdata', 'sec_filings.db').to_s
  end

  let(:test_db) do
    Sec::Database.new(path: test_db_path, readonly: true)
  end

  let(:form4_xml) do
    File.read Rails.root.join('spec', 'testdata', 'sec', '0000769993-14-000090.txt').to_s
  end

  let(:form8k_xml) do
    File.read Rails.root.join('spec', 'testdata', 'sec', '0000034088-19-000032.txt').to_s
  end

  let(:avantor_xml) do
    File.read Rails.root.join('spec', 'testdata', 'sec', '0000769993-19-000383.txt').to_s
  end

  describe 'verify_cik!' do
    specify do
      expect { Sec.verify_cik!('') }.to raise_error(Sec::InvalidCikNumber)
    end

    specify do
      expect { Sec.verify_cik!('123') }.to raise_error(Sec::InvalidCikNumber)
    end

    specify do
      expect { Sec.verify_cik!('0000886982') }.not_to raise_error
    end
  end

  describe Sec::Database do
    it 'setups db' do
      expect(SQLite3::Database).to receive(:new)
                                     .with('/tmp/db',
                                           readonly: false,
                                           results_as_hash: true).once
      Sec::Database.new(path: '/tmp/db')
    end

    describe '#forms' do
      it 'queries for all filings by default' do
        expect(test_db.forms.length).to eq 6
      end

      it 'can set limit' do
        expect(test_db.forms(limit: 3).length).to eq 3
      end

      it 'can set offset' do
        expect(test_db.forms(offset: 4).length).to eq 2
      end

      it 'retrieves filings for Goldman Sachs' do
        expect(test_db.forms(cik: Sec::CIKS.fetch('GS')).length).to eq(3)
      end

      it 'retrieves filings for Netflix' do
        expect(test_db.forms(cik: "0001065280").length).to eq(1)
      end

      it 'filters by form type' do
        expect(
          test_db.forms(
            cik: Sec::CIKS.fetch('GS'),
            form_types: ['3']
          ).length
        ).to eq 1
      end
    end
  end

  describe Sec::Filing do
    context 'with form 4' do
      let(:metadata) do
         { "cik" => "886982",
           "company_name" => "GOLDMAN SACHS GROUP INC",
           "form_type" => "4",
           "date_filed" => "2014-02-05",
           "filename" => "edgar/data/886982/0000769993-14-000090.txt" } 
      end

      let(:filing_with_data) do
        Sec::Filing.new(metadata: metadata, data: form4_xml)
      end

      let(:filing_without_data) do
        Sec::Filing.new(metadata: metadata, data: nil)
      end

      specify do
        expect(filing_with_data.url).to eq "https://www.sec.gov/Archives/edgar/data/886982/0000769993-14-000090.txt"
      end

      it 'raises error if download fails' do
        filing_without_data.download = true
        expect(Sec::Filing).to receive(:download)
                                 .once
                                 .with("https://www.sec.gov/Archives/edgar/data/886982/0000769993-14-000090.txt")
                                 .and_return(nil)

        expect { filing_without_data.to_h }.to raise_error(Sec::Filing::MissingDocumentError)
      end
    end
  end

  describe Sec::Document do
    context 'with form 4 document' do
      let(:document) { Sec::Document.new(form4_xml) }

      it 'set @data' do
        expect(document.data).to eq form4_xml
      end
      
      it 'sets @text and @document' do
        expect(document.text).to be_a String
        expect(document.document).to be_a Nokogiri::XML::Document
      end

      it 'set @hash' do
        expect(document.hash).to be_a Hash
        expect(document.hash.key?('ownershipDocument')).to be true
      end

      it 'returns issuer, type, period_of_report' do
        expect(document.type).to eq('4')
        expect(document.issuer)
            .to eql("issuerCik" => "0000886982", "issuerName" => "GOLDMAN SACHS GROUP INC", "issuerTradingSymbol" => "GS")
        expect(document.period_of_report).to eq "2014-02-03-05:00"
      end

      it 'wraps reporting owner in an array'  do
        expect(document.reporting_owners.length).to eq 1
      end
    end

    context 'with form 8k' do
      let(:document) { Sec::Document.new(form8k_xml) }

      it 'set @data' do
        expect(document.data).to eq form8k_xml
      end
      
      it 'sets @text and @document' do
        expect(document.text).to be_a String
        expect(document.document).to be_a Nokogiri::HTML::Document
      end

      it 'hash is nil' do
        expect(document.hash).to be nil
      end
    end

    describe 'avantor = multiple owners' do
      let(:metadata) do
         { "cik" => "886982",
           "company_name" => "GOLDMAN SACHS GROUP INC",
           "form_type" => "4",
           "date_filed" => "2019-05-21",
           "filename" => "edgar/data/886982/0000769993-19-000383.txt",
           "data" => nil }
      end

      let(:filing) do
        Sec::Filing.new(metadata: metadata, data: avantor_xml)
      end

      specify do
        expect(filing.document.type).to eq '4'
      end

      specify do
        expect(filing.document.reporting_owners.length).to eq 9
      end

      specify do
        expect(filing.document.reporting_owners.map { |o| o.dig("reportingOwnerId", "rptOwnerCik") })
          .to eql %w[0000769993 0000886982 0001698770 0001698772 0001729503 0001575993 0001708241 0001729502 0001615636]
      end
    end
  end

  describe Sec::Company do
    it 'has 3 goldman filings' do
      expect(test_db.company(Sec::CIKS.fetch('GS')).filings.length).to eq 3
    end
  end

  # describe Sec::ReportingOwner do

    
  # end

  describe Sec::Roster do
    let(:netflix_cik) { '0001065280' }

    let(:roster_hash) do
      {
        "0001082906" => [
          { "reportingOwnerId" => {
              "rptOwnerCik" => "0001082906",
              "rptOwnerName" => "HOAG JAY C"
            },
            "reportingOwnerAddress" => {
              "rptOwnerStreet1" => "C/O TECHNOLOGY CROSSOVER VENTURES",
              "rptOwnerStreet2" => "528 RAMONA STREET",
              "rptOwnerCity" => "PALO ALTO",
              "rptOwnerState" => "CA",
              "rptOwnerZipCode" => "94301",
              "rptOwnerStateDescription" => nil
            },
            "reportingOwnerRelationship" => {
              "isDirector" => "1",
              "isOfficer" => "0",
              "isTenPercentOwner" => "0",
              "isOther" => "0"
            },
            "metadata" => {
              'cik' => "1065280",
              'company_name' => "NETFLIX INC",
              'form_type' => "4",
              'date_filed' => "2014-10-03",
              'filename' => "edgar/data/1065280/0001082906-14-000050.txt"
            }
          }
        ]
      }
    end
    specify do
      expect(test_db.company(netflix_cik).roster.to_h).to eq roster_hash
    end
  end
end

#   describe Sec::BeneficialOwnershipForm do
#     describe 'Netflix - single owner on doc' do
#       let(:xml_data) do
#         File.read Rails.root.join('spec', 'testdata', 'sec', 'netflix.xml')
#       end

#       let(:form4) { Sec::BeneficialOwnershipForm.new(xml_data) }

#       specify do
#         expect(form4.to_h)
#           .to eq(period_of_report: '2019-07-22',
#                  form_type: '4',
#                  issuer: {
#                    cik: '0001065280',
#                    name: 'NETFLIX INC',
#                    trading_symbol: 'NFLX'
#                  },
#                  reporting_owners: [
#                    {
#                      cik: '0001033331',
#                      name: 'HASTINGS REED',
#                      is_director: true,
#                      is_officer: true,
#                      is_ten_percent: false,
#                      is_other: false,
#                      officer_title: 'CEO'
#                    }
#                  ],
#                  signatures: [
#                    {
#                      name: 'By: Veronique Bourdeau, Authorized Signatory For: Reed Hastings',
#                      date: '2019-07-23'
#                    }
#                  ])
#       end
#     end

#     describe 'avantor = multiple owners' do
#       let(:xml_data) do
#         File.read Rails.root.join('spec', 'testdata', 'sec', 'avantor.xml')
#       end

#       let(:form4) { Sec::BeneficialOwnershipForm.new(xml_data) }

#       specify do
#         expect(form4.to_h.fetch(:form_type)).to eq '4'
#       end

#       specify do
#         expect(form4.to_h.fetch(:reporting_owners).map { |o| o[:cik] })
#           .to eql %w[0000769993 0000886982 0001698770 0001698772 0001729503 0001575993 0001708241 0001729502 0001615636]
#       end
#     end

#     describe 'goldman sachs - form 3' do
#       let(:xml_data) do
#         File.read Rails.root.join('spec', 'testdata', 'sec', 'goldman.xml')
#       end

#       let(:form3) { Sec::BeneficialOwnershipForm.new(xml_data) }

#       specify do
#         expect(form3.to_h.fetch(:form_type)).to eq '3'
#       end
#     end
#   end # end Sec::BeneficialOwnershipForm

require 'sec'

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
        expect(filing.reporting_owners.first)
          .to eq('cik' => '0000769993',
                 'name' => 'GOLDMAN SACHS & CO. LLC',
                 'location' => 'NEW YORK NY 10282',
                 'is_director' => 'false',
                 'is_officer' => 'false',
                 'is_ten_percent_owner' => 'true',
                 'is_other' => 'false',
                 'officer_title' => nil,
                 'filename' => 'edgar/data/886982/0000769993-19-000383.txt',
                 'date_filed' => '2019-05-21')
      end

      specify do
        expect(filing.document.reporting_owners.map { |o| o.cik })
          .to eql %w[0000769993 0000886982 0001698770 0001698772 0001729503 0001575993 0001708241 0001729502 0001615636]
      end
    end
  end

  describe Sec::Company do
    it 'has 3 goldman filings' do
      expect(test_db.company(Sec::CIKS.fetch('GS')).filings.length).to eq 3
    end
  end

  describe Sec::ReportingOwner do
    subject(:reporting_owner) { Sec::ReportingOwner.new(reporting_owner_hash) }

    let(:document_hash) do
      JSON.load(File.read(Rails.root.join('spec', 'testdata', 'sec', 'eep_document.json').to_s))
    end

    let(:reporting_owner_hash) do
      document_hash.dig('document', 'ownershipDocument', 'reportingOwner')
    end

    specify { expect(reporting_owner.cik).to eq "0001502992" }
    specify { expect(reporting_owner.name).to eq "Neyland Stephen J" }
    specify { expect(reporting_owner.location).to eq "HOUSTON TX 77056" }
    specify { expect(reporting_owner.is_director).to eq "1" }
    specify { expect(reporting_owner.is_officer).to eq "1" }
    specify { expect(reporting_owner.is_ten_percent_owner).to eq "0" }
    specify { expect(reporting_owner.is_other).to eq "0" }
    specify { expect(reporting_owner.officer_title).to eq "Vice President" }
  end

  describe Sec::Roster do
    let(:netflix_cik) { '0001065280' }

    let(:roster_hash) do
      {
        "0001082906" => [
          {
            "cik" => "0001082906",
            "name" => "HOAG JAY C",
            "location" => "PALO ALTO CA 94301",
            "is_director" => "1",
            "is_officer" => "0",
            "is_ten_percent_owner" => "0",
            "is_other" => "0",
            "officer_title" => nil,
            "filename" => "edgar/data/1065280/0001082906-14-000050.txt",
            "date_filed" => '2014-10-03'
          }
        ]
      }
    end

    specify do
      expect(test_db.company(netflix_cik).roster.to_h).to eq roster_hash
    end
  end
end

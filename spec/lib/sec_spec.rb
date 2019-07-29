describe Sec do
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

  describe Sec::FilingsDb do
    let(:test_db_path) do
      Rails.root.join('spec', 'testdata', 'sec_filings.db').to_s
    end

    it 'setups db' do
      expect(SQLite3::Database).to receive(:new).with('/tmp/db',
                                                      readonly: false,
                                                      results_as_hash: true
                                                     ).once
      Sec::FilingsDb.new(database: '/tmp/db')
    end

    it 'retrives filings for goldman' do
      db = Sec::FilingsDb.new(database: test_db_path, readonly: true)
      expect(db.filings_for(Sec::CIKS.fetch('GS')).length).to eq 3
    end

    it 'filters by form type' do
      db = Sec::FilingsDb.new(database: test_db_path,
                              forms: ['3'],
                              readonly: true)
      expect(db.filings_for(Sec::CIKS.fetch('GS')).length).to eq 1
    end
  end # end FilingsDb

  describe Sec::Document do 
    let(:xml_data) do
      File.read Rails.root.join('spec', 'testdata', 'netflix.xml')
    end

    let(:document) do
      Sec::Document.new(form_type: '4', data: xml_data)
    end

    specify do
      expect(document.to_h)
        .to eq(period_of_report: '2019-07-22',
               issuer_cik: '0001065280',
               issuer_name: 'NETFLIX INC',
               issuer_trading_symbol: 'NFLX',
               owner_cik: '0001033331',
               owner_name: 'HASTINGS REED',
               owner_is_director: true,
               owner_is_officer: true,
               owner_is_ten_percent: false,
               owner_is_other: false,
               owner_officer_title: 'CEO',
               owner_signature_name: 'By: Veronique Bourdeau, Authorized Signatory For: Reed Hastings',
               owner_signature_date: '2019-07-23')
    end
  end
end

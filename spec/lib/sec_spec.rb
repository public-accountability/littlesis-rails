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
      expect(SQLite3::Database).to receive(:new).with('/tmp/db', readonly: false).once
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
  end
end

describe Sec do
  let(:test_db_path) do
    Rails.root.join('spec', 'testdata', 'sec_filings.db').to_s
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

  describe Sec::FilingsDb do
    let(:db) do
      Sec::FilingsDb.new(database: test_db_path, readonly: true)
    end

    it 'setups db' do
      expect(SQLite3::Database).to receive(:new)
                                     .with('/tmp/db',
                                           readonly: false,
                                           results_as_hash: true).once
      Sec::FilingsDb.new(database: '/tmp/db')
    end

    it 'retrives filings for goldman' do
      expect(db.filings_for(Sec::CIKS.fetch('GS')).length).to eq(3)
    end

    it 'retrives filings for netflix' do
      expect(db.filings_for("0001065280").length).to eq 1
    end

    it 'filters by form type' do
      db = Sec::FilingsDb.new(database: test_db_path,
                              forms: ['3'],
                              readonly: true)
      expect(db.filings_for(Sec::CIKS.fetch('GS')).length).to eq 1
    end
  end # end FilingsDb

  describe Sec::BeneficialOwnershipForm do
    describe 'Netflix - single owner on doc' do
      let(:xml_data) do
        File.read Rails.root.join('spec', 'testdata', 'sec', 'netflix.xml')
      end

      let(:form4) { Sec::BeneficialOwnershipForm.new(xml_data) }

      specify do
        expect(form4.to_h)
          .to eq(period_of_report: '2019-07-22',
                 form_type: '4',
                 issuer: {
                   cik: '0001065280',
                   name: 'NETFLIX INC',
                   trading_symbol: 'NFLX'
                 },
                 reporting_owners: [
                   {
                     cik: '0001033331',
                     name: 'HASTINGS REED',
                     is_director: true,
                     is_officer: true,
                     is_ten_percent: false,
                     is_other: false,
                     officer_title: 'CEO'
                   }
                 ],
                 signatures: [
                   {
                     name: 'By: Veronique Bourdeau, Authorized Signatory For: Reed Hastings',
                     date: '2019-07-23'
                   }
                 ])
      end
    end

    describe 'avantor = multiple owners' do
      let(:xml_data) do
        File.read Rails.root.join('spec', 'testdata', 'sec', 'avantor.xml')
      end

      let(:form4) { Sec::BeneficialOwnershipForm.new(xml_data) }

      specify do
        expect(form4.to_h.fetch(:form_type)).to eq '4'
      end

      specify do
        expect(form4.to_h.fetch(:reporting_owners).map { |o| o[:cik] })
          .to eql %w[0000769993 0000886982 0001698770 0001698772 0001729503 0001575993 0001708241 0001729502 0001615636]
      end
    end

    describe 'goldman sachs - form 3' do
      let(:xml_data) do
        File.read Rails.root.join('spec', 'testdata', 'sec', 'goldman.xml')
      end

      let(:form3) { Sec::BeneficialOwnershipForm.new(xml_data) }

      specify do
        expect(form3.to_h.fetch(:form_type)).to eq '3'
      end
    end
  end # end Sec::BeneficialOwnershipForm

  describe Sec::Company do
    let(:db) do
      Sec::FilingsDb.new(database: test_db_path, readonly: true)
    end

    it 'has 3 goldman filings' do
      expect(db.company(Sec::CIKS.fetch('GS')).filings.length).to eq 3
    end

    it 'has a goldman self filings' do
      expect(db.company(Sec::CIKS.fetch('GS')).self_filings.length).to eq 1
    end
  end

  describe Sec::Roster do
    let(:db) do
      Sec::FilingsDb.new(database: test_db_path, readonly: true)
    end

    let(:netflix_cik) { '0001065280' }

    specify do
      expect(db.company(netflix_cik).roster.to_h)
        .to eq('0001082906' => [{
                                  :cik => '0001082906',
                                  :name => 'HOAG JAY C',
                                  :is_director => true,
                                  :is_officer => false,
                                  :is_ten_percent => false,
                                  :is_other => false,
                                  :officer_title => nil,
                                  :filename => 'edgar/data/1065280/0001082906-14-000050.txt',
                                  :period_of_report => '2014-10-01'
                                }])
    end
  end
end

require 'os_importer'

describe 'os_importer' do

  before(:all) do
    filepath = Rails.root.join('spec', 'testdata', 'indivs14_sample.txt')
    OsImporter.import_indivs filepath
  end

  after(:all) do
    OsDonation.delete_all
  end

  let(:d1) do
    OsDonation.find_by fectransid: "1010620150016543738"
  end

  let(:d2) do
    OsDonation.find_by fectransid: "1010620150016544655"
  end

  let(:d3) do
    OsDonation.find_by fectransid: "1010620150016544835"
  end

  describe 'bulk insert of test data' do

    it 'adds 3 donations' do
      expect(OsDonation.count).to eq(3)
    end

    it 'inserts correct data' do
      expect(d1.contribid).to eq("h1001161847")
      expect(d1.contrib).to eq('DANTCHIK, ARTHUR MR')
      expect(d1.recipid).to eq('N00009573')
      expect(d1.realcode).to eq('F2100')
      expect(d1.city).to eq('GLADWYNE')
      expect(d1.state).to eq('PA')
      expect(d1.zip).to eq('19035')
      expect(d1.recipcode).to eq('RI')
      expect(d1.transactiontype).to eq('15J')
      expect(d1.cmteid).to eq('C00347260')
      expect(d1.gender).to eq('M')
      expect(d1.microfilm).to be_nil
      expect(d1.occupation).to eq('MANAGING DIRECTOR')
      expect(d1.employer).to eq('SUSQUEHANNA INTERNATIONAL')
      expect(d1.source).to eq('hvr13')
    end

    it 'has correct amount fields' do
      expect(d1.amount).to eq(2600)
      expect(d2.amount).to eq(2600)
      expect(d3.amount).to eq(250)
    end

    it 'parses date' do
      expect(d1.date.mon).to eq(2)
      expect(d1.date.mday).to eq(27)
      expect(d1.date.year).to eq(2014)
      expect(d2.date.mon).to eq(5)
      expect(d2.date.mday).to eq(14)
      expect(d2.date.year).to eq(2014)
    end

    it 'handles null fields' do
      expect(d1.otherid).to be_nil
      expect(d2.ultorg).to be_nil
      expect(d2.street).to be_nil
    end

    it 'creates fec_cycle_id' do
      expect(d1.fec_cycle_id).to eq('2014_1010620150016543738')
      expect(d2.fec_cycle_id).to eq('2014_1010620150016544655')
      expect(d3.fec_cycle_id).to eq('2014_1010620150016544835')
    end

    it 'creates parsed name columns' do
      expect(d1.name_last).to eq('Dantchik')
      expect(d1.name_first).to eq('Arthur')
      expect(d1.name_prefix).to eq('Mr')
      expect(d1.name_suffix).to be_nil
      expect(d1.name_middle).to be_nil

      expect(d2.name_first).to eq('Peter')
      expect(d2.name_last).to eq('Wallace')

      expect(d3.name_last).to eq('Salmon')
      expect(d3.name_first).to eq('Thaddeus')
      expect(d3.name_prefix).to eq('Mr')
    end

    describe 'upon re-inserting the same data' do
      with_versioning do

        it 'does not add duplicate donations' do
          expect(OsDonation.count).to eq(3)
          filepath = Rails.root.join('spec', 'testdata', 'indivs14_sample.txt')
          OsImporter.import_indivs filepath
          expect(OsDonation.count).to eq(3)
          expect(OsDonation.find_by(fectransid: "1010620150016543738").versions.size).to eq(0)
          expect(OsDonation.find_by(fectransid: "1010620150016544655").versions.size).to eq(0)
          expect(OsDonation.find_by(fectransid: "1010620150016544835").versions.size).to eq(0)
        end

        describe 'upon inserting updated data' do
          before do
            filepath = Rails.root.join('spec', 'testdata', 'indivs14_sample_modified.txt')
            OsImporter.import_indivs filepath
          end

          it 'does not add duplicate donations' do
            expect(OsDonation.count).to eq(3)
          end

          it 'updates modified donation' do
            d = OsDonation.find_by fectransid: "1010620150016544655"
            expect(d.contribid).to eq('xNewID00000')
            expect(d.versions.size).to eq(1)
          end

          it 'does not update unchanged donations' do
            d1 = OsDonation.find_by fectransid: "1010620150016543738"
            d3 = OsDonation.find_by fectransid: "1010620150016544835"
            expect(d1.versions.size).to eq(0)
            expect(d3.versions.size).to eq(0)
          end
        end
      end
    end

    describe "malformed lines" do
      before do
        @count = OsDonation.count
        filepath = Rails.root.join('spec', 'testdata', 'indivs14_bad_lines.txt')
        OsImporter.import_indivs filepath
      end

      it 'can deal with the BAD lines. no problem.' do
        expect(OsDonation.count).to eq(@count + 3)
      end
    end

    describe "lines with blank date" do
      before do
        @count = OsDonation.count
        filepath = Rails.root.join('spec', 'testdata', 'lines_without_dates.txt')
        OsImporter.import_indivs filepath
      end

      it 'can handle lines without dates' do
        expect(OsDonation.count).to eq(@count + 2)
      end
    end

    describe 'remove_spaces_between_quoted_field_and_comma' do
      it "Fix weird spacing causing malformed csv errors" do
        line = "|GA|,||     ,|DI|,|,||         ,|PAC|"
        fixed = OsImporter.remove_spaces_between_quoted_field_and_comma(line)
        expect(fixed).to eq("|GA|,||,|DI|,|,||,|PAC|")
      end
    end
  end
end

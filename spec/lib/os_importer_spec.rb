require 'rails_helper'

describe 'os_importer' do
  
  before do 
    filepath = Rails.root.join('spec', 'testdata', 'indivs14_sample.txt')
    OsImporter.import_indivs filepath
    @d1 = OsDonation.find_by fectransid: "1010620150016543738"
    @d2 = OsDonation.find_by fectransid: "1010620150016544655"
    @d3 = OsDonation.find_by fectransid: "1010620150016544835"
  end

  describe 'bulk insert of test data' do
    
    it 'adds 3 donations' do 
      expect(OsDonation.count).to eql(3)
    end
    
    it 'inserts correct data' do
      expect(@d1.contribid).to eql("h1001161847")
      expect(@d1.contrib).to eql('DANTCHIK, ARTHUR MR')
      expect(@d1.recipid).to eql('N00009573')
      expect(@d1.realcode).to eql('F2100')
      expect(@d1.city).to eql('GLADWYNE')
      expect(@d1.state).to eql('PA')
      expect(@d1.zip).to eql('19035')
      expect(@d1.recipcode).to eql('RI')
      expect(@d1.transactiontype).to eql('15J')
      expect(@d1.cmteid).to eql('C00347260')
      expect(@d1.gender).to eql('M')
      expect(@d1.microfilm).to be_nil
      expect(@d1.occupation).to eql('MANAGING DIRECTOR')
      expect(@d1.employer).to eql('SUSQUEHANNA INTERNATIONAL')
      expect(@d1.source).to eql('hvr13')
    end

    it 'has correct amount fields' do
      expect(@d1.amount).to eql(2600)
      expect(@d2.amount).to eql(2600)
      expect(@d3.amount).to eql(250)
    end

    it 'parses date' do 
      expect(@d1.date.mon).to eql(2)
      expect(@d1.date.mday).to eql(27)
      expect(@d1.date.year).to eql(2014)
      expect(@d2.date.mon).to eql(5)
      expect(@d2.date.mday).to eql(14)
      expect(@d2.date.year).to eql(2014)
    end
    
    it 'handles null fields' do 
      expect(@d1.otherid).to be_nil
      expect(@d2.ultorg).to be_nil
      expect(@d2.street).to be_nil
    end
    
    it 'creates fec_cycle_id' do
      expect(@d1.fec_cycle_id).to eql('2014_1010620150016543738')
      expect(@d2.fec_cycle_id).to eql('2014_1010620150016544655')
      expect(@d3.fec_cycle_id).to eql('2014_1010620150016544835')
    end

    it 'creates parsed name columns' do 
      expect(@d1.name_last).to eql('Dantchik')
      expect(@d1.name_first).to eql('Arthur')
      expect(@d1.name_prefix).to eql('Mr')
      expect(@d1.name_suffix).to be_nil
      expect(@d1.name_middle).to be_nil
      
      expect(@d2.name_first).to eql('Peter')
      expect(@d2.name_last).to eql('Wallace')

      expect(@d3.name_last).to eql('Salmon')
      expect(@d3.name_first).to eql('Thaddeus')
      expect(@d3.name_prefix).to eql('Mr')

    end

    context 'upon re-inserting the same data' do 
      with_versioning do 

        it 'does not add duplicate donations' do 
          filepath = Rails.root.join('spec', 'testdata', 'indivs14_sample.txt')
          OsImporter.import_indivs filepath
          expect(OsDonation.count).to eql(3)
          expect(OsDonation.find_by(fectransid: "1010620150016543738").versions.size).to eql(0)
          expect(OsDonation.find_by(fectransid: "1010620150016544655").versions.size).to eql(0)
          expect(OsDonation.find_by(fectransid: "1010620150016544835").versions.size).to eql(0)
        end
        
      
        context 'upon inserting updated data' do 
          before do 
            filepath = Rails.root.join('spec', 'testdata', 'indivs14_sample_modified.txt')
            OsImporter.import_indivs filepath
          end

          it 'does not add duplicate donations' do 
            expect(OsDonation.count).to eql(3)
          end

          it 'updates modified donation' do 
            d = OsDonation.find_by fectransid: "1010620150016544655"
            expect(d.contribid).to eql('xNewID00000')
            expect(d.versions.size).to eql(1)
          end
          
          it 'does not update unchanged donations' do 
            d1 = OsDonation.find_by fectransid: "1010620150016543738"
            d3 = OsDonation.find_by fectransid: "1010620150016544835"
            expect(d1.versions.size).to eql(0)
            expect(d3.versions.size).to eql(0)
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
        expect(OsDonation.count).to eql(@count + 1)
      end
    end
    
  end
end

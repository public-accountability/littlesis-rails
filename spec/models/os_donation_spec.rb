RSpec.describe OsDonation, type: :model do

  describe 'create_fec_cycle_id' do 
    it 'creates id' do 
      d = OsDonation.new
      d.cycle = '2010'
      d.fectransid = '123'
      expect(d.fec_cycle_id).to be_nil
      d.create_fec_cycle_id
      expect(d.fec_cycle_id).to eql('2010_123')
    end
  end


  describe 'Reference Helper Methods' do
    before(:all) do
      @d = OsDonation.new
      @d.microfilm = '123'
    end

    describe 'reference_name' do
      
      it 'returns the reference name using microfilm' do 
        expect(@d.reference_name).to eql "FEC Filing 123"
      end
      it 'returns the reference name when  microfilm is nil' do 
        d = OsDonation.new
        expect(d.reference_name).to eql "FEC Filing "
      end
    end

    describe 'reference_source' do 
      
      it 'returns general search link if microfilm is nil' do 
        d = OsDonation.new
        expect(d.reference_source).to eql "http://www.fec.gov/finance/disclosure/advindsea.shtml"
      end

      it 'returns link to fec img' do
        expect(@d.reference_source).to eql "http://docquery.fec.gov/cgi-bin/fecimg/?123"
      end
      
    end
  end
end

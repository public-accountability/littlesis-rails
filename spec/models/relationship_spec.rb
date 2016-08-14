require 'rails_helper'

describe Relationship, type: :model do
  before(:all) do 
    Entity.skip_callback(:create, :after, :create_primary_ext)
  end
  after(:all) do 
    Entity.set_callback(:create, :after, :create_primary_ext)
  end

  describe 'Update Start/End dates' do 

    describe '#date_string_to_date' do 
     
      it 'returns nil if no date' do
        r = build(:loeb_donation, start_date: nil)
        expect(r.date_string_to_date(:start_date)).to be_nil
      end

      it 'returns nil if bad year' do
        r = build(:loeb_donation, start_date: "badd-00-00")
        expect(r.date_string_to_date(:start_date)).to be_nil
      end
      
     it 'converts "2012-00-00"' do 
        r = build(:loeb_donation)
        expect(r.date_string_to_date(:start_date)).to eq Date.new(2010)
     end

    it 'converts "2012-12-00"' do 
      r = build(:loeb_donation, start_date: "2012-12-00")
      expect(r.date_string_to_date(:start_date)).to eq Date.new(2012, 12)
    end

    it 'converts "2012-04-10"' do 
      r = build(:loeb_donation, start_date: "2012-4-10")
      expect(r.date_string_to_date(:start_date)).to eq Date.new(2012, 4, 10)
    end
    
  end
      
    end
    describe '#update_start_date_if_earlier' do
      before(:all) do 
        # start date: 2010
        # end date: 2011
        @loeb = create(:loeb)
        @nrsc = create(:nrsc)
        @loeb_donation = create(:loeb_donation) # relationship model        
      end
      
      it 'updates start date' do 
        @loeb_donation.update_start_date_if_earlier Date.new(1999)
        expect(@loeb_donation.start_date).to eql('1999-01-01')
      end 

      it 'updates end date' do 
        @loeb_donation.update_end_date_if_later Date.new(2012)
        expect(@loeb_donation.end_date).to eql('2012-01-01')
      end
      
      it 'does not change if not earlier' do 
        @loeb_donation.update_start_date_if_earlier Date.new(2010)
        expect(@loeb_donation.start_date).to eql('1999-01-01')
      end

      it 'does not change if not later' do 
        @loeb_donation.update_end_date_if_later Date.new(2010)
        expect(@loeb_donation.end_date).to eql('2012-01-01')
      end
      
  end
end

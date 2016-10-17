require 'rails_helper'

describe NyDisclosure, type: :model do
  it { should have_one(:ny_match) }
  it { should belong_to(:ny_filer) }

  describe '#full_name' do 
    
    it 'returns corp_name if it exists' do 
      d = build(:ny_disclosure, corp_name: 'corp inc')
      expect(d.full_name).to eql 'corp inc'
    end

    it 'returns formatted name' do 
      d = build(:ny_disclosure, first_name: 'ALICE', last_name: 'COLTRANE')
      expect(d.full_name).to eql 'Alice Coltrane'
      d2 = build(:ny_disclosure, first_name: 'ALICE', last_name: 'COLTRANE', mid_init: 'X')
      expect(d2.full_name).to eql 'Alice X Coltrane'
    end
    
    it 'returns nil otherwise' do 
      d = build(:ny_disclosure)
      expect(d.full_name).to be nil
    end

  end

end

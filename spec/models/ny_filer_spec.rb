require 'rails_helper'

describe NyFiler, type: :model do
  
  it { should have_one(:ny_filer_entity) }
  it { should have_many(:entities) }
  it { should have_many(:ny_disclosures) }

  describe 'is_matched' do 
    
    it 'returns true if there is a filer_entity' do
      ny_filer = create(:ny_filer, filer_id: '123')
      create(:ny_filer_entity, ny_filer_id: ny_filer.id)
      expect(ny_filer.is_matched?).to be true
    end

    it 'returns false if there is no filer_entity' do
      ny_filer = create(:ny_filer, filer_id: '123')
      expect(ny_filer.is_matched?).to be false
    end
    
  end

end

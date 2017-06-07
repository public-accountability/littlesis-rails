require 'rails_helper'

describe NyFiler, type: :model do
  subject { create(:ny_filer) }
  it { should have_one(:ny_filer_entity) }
  it { should have_many(:entities) }
  it { should have_many(:ny_disclosures) }
  it { should validate_presence_of(:filer_id) }
  it { should validate_uniqueness_of(:filer_id) }

  it 'has OFFICES constant' do
    expect(NyFiler::OFFICES).to be_a Hash
  end
  
  describe '#office_description' do
    it 'translates numeric office code to text description' do
      filer = build(:ny_filer, office: 22)
      expect(filer.office_description).to eq 'Mayor'
    end

    it 'returns nils if code is missing from lookup hash' do
      filer = build(:ny_filer, office: 100)
      expect(filer.office_description).to be nil
    end
  end

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

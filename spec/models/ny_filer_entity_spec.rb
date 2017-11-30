require 'rails_helper'

describe NyFilerEntity, type: :model do
  it { should belong_to(:ny_filer) }
  it { should belong_to(:entity) }
  it { should validate_presence_of(:ny_filer_id) }
  it { should validate_presence_of(:entity_id) }
  it { should validate_presence_of(:filer_id) }
  it { should callback(:rematch_existing_matches).after(:create) }

  describe "associations" do
    let(:elected) { create(:entity_person, name: 'Elected Representative') }
    let(:ny_filer) { create(:ny_filer, filer_id: 'A1') }
    let(:filer_entity) { NyFilerEntity.create!(entity: elected, ny_filer: ny_filer, filer_id: 'A1') }

    it "belongs to entity" do
      expect(filer_entity.entity).to eql elected
      expect(elected.ny_filer_entities.length).to eql 1
      expect(elected.ny_filer_entities[0].id).to eq filer_entity.id
    end

    it "belongs to ny_filer" do
      expect(filer_entity.ny_filer).to eql ny_filer
      expect(ny_filer.entities.length).to eql 1
      expect(ny_filer.ny_filer_entity.present?).to be true
      expect(ny_filer.entities[0].id).to eql elected.id
      expect(ny_filer.ny_filer_entity.id).to eql filer_entity.id
    end
  end

  describe 'rematch_existing_matches' do
    it 'calls rematch on NyMatch for models' do
      elected = create(:elected)
      donor = create(:entity_person)
      ny_filer = create(:ny_filer, filer_id: 'A2')
      NyFilerEntity.create!(entity: elected, ny_filer: ny_filer, filer_id: 'A2')
      ny_disclosure = create(:ny_disclosure, ny_filer: ny_filer)
      NyMatch.create(ny_disclosure: ny_disclosure, donor_id: donor.id)
      expect(NyMatch.last.recip_id).to be nil
      expect{NyFilerEntity.last.rematch_existing_matches_without_delay}.to change{Relationship.count}.by(1)
      expect(NyMatch.last.recip_id).to eql elected.id
    end
  end
end

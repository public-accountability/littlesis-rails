describe ExternalRelationship, type: :model do
  it { is_expected.to belong_to(:external_data) }
  it { is_expected.to belong_to(:relationship).optional }
  it { is_expected.to have_db_column(:dataset).of_type(:integer) }
  it { is_expected.to have_db_column(:entity1_id).of_type(:integer) }
  it { is_expected.to have_db_column(:entity2_id).of_type(:integer) }
  it { is_expected.to have_db_column(:category_id).of_type(:integer) }
  it { is_expected.to have_db_column(:relationship_attributes).of_type(:text) }

  specify 'matched?' do
    expect(ExternalRelationship.new.matched?).to be false
    expect(build(:external_relationship,relationship: build(:generic_relationship)).matched?)
      .to be true
  end

  describe 'set_entity' do
    let(:entity1) { build(:org) }
    let(:entity2) { build(:org) }
    let(:external_relationship) do
      create(:external_relationship, category_id: 12, external_data: create(:external_data_iapd_advisor), dataset: 'iapd_advisors')
    end

    it 'sets entity1 and entity2' do
      expect(external_relationship.entity1_id).to be nil
      expect(external_relationship.entity2_id).to be nil
      external_relationship.set_entity(entity1: entity1, entity2: entity2)
      expect(external_relationship.entity1_id).to eq entity1.id
      expect(external_relationship.entity2_id).to be entity2.id
    end

    it 'sets raises error if already set' do
      external_relationship.set_entity(entity1: entity1)
      expect { external_relationship.set_entity(entity1: 123) }
        .to raise_error(ExternalRelationship::EntityAlreadySetError)
    end
  end

  describe 'create_new_relationship' do
    let(:entity1) { create(:entity_person) }
    let(:entity2) { create(:entity_org) }

    it 'errors if already matched' do
      er = build(:external_relationship, relationship: build(:generic_relationship))
      expect { er.create_new_relationship }.to raise_error(ExternalRelationship::AlreadyMatchedError)
    end

    it 'errors unless both entity1 and entity2 are set' do
      er = create(:external_relationship_schedule_a, entity1_id: entity1.id)
      expect { er.create_new_relationship }.to raise_error(ExternalRelationship::MissingMatchedEntityError)
    end

    it 'creates a new relationship' do
      er = create(:external_relationship_schedule_a, entity1_id: entity1.id, entity2_id: entity2.id)
      expect { er.create_new_relationship }.to change(Relationship, :count).by(1)
    end

    it 'sets relationship id on the external relationship model' do
      er = create(:external_relationship_schedule_a, entity1_id: entity1.id, entity2_id: entity2.id)
      expect { er.create_new_relationship }
        .to change(er, :relationship_id).from(nil)
    end

    it 'updates relationship attributes' do
      er = create(:external_relationship_schedule_a,
                  entity1_id: entity1.id,
                  entity2_id: entity2.id,
                  relationship_attributes: { 'description1' => 'CEO' } )
      er.create_new_relationship
      expect(er.relationship.description1).to eq 'CEO'
    end

    it 'updates extension attributes' do
      er = create(:external_relationship_schedule_a,
                  entity1_id: entity1.id,
                  entity2_id: entity2.id,
                  relationship_attributes: {
                    'description1' => 'CEO',
                    'ownership_attributes' => { 'shares': 10_000 }
                  })
      er.create_new_relationship
      expect(er.relationship.ownership.shares).to eq 10_000
    end
  end
end

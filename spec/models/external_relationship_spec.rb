describe ExternalRelationship, type: :model do
  describe 'associations and database columns' do
    subject { build(:external_relationship) }

    it { is_expected.to belong_to(:external_data) }
    it { is_expected.to belong_to(:relationship).optional }
    it { is_expected.to have_db_column(:dataset).of_type(:integer) }
    it { is_expected.to have_db_column(:entity1_id).of_type(:integer) }
    it { is_expected.to have_db_column(:entity2_id).of_type(:integer) }
    it { is_expected.to have_db_column(:category_id).of_type(:integer) }
  end

  specify 'matched?' do
    expect(build(:external_relationship).matched?).to be false
    expect(build(:external_relationship, relationship: build(:generic_relationship)).matched?).to be true
  end

  describe 'set_entity' do
    let(:entity1) { create(:entity_person) }
    let(:entity2) { create(:entity_org) }
    let(:external_relationship) do
      create(:external_relationship_schedule_a, category_id: 1, external_data: create(:external_data_schedule_a))
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

  describe 'match_action' do
    let!(:external_relationship) do
      create(:external_relationship_schedule_a, category_id: 1, external_data: create(:external_data_schedule_a))
    end

    let(:entity1) { create(:entity_person) }
    let(:entity2) { create(:entity_org) }

    it 'raises error unless both entity2 and entity2 are matched' do
      expect { external_relationship.match_action }
        .to raise_error(ExternalRelationship::MissingMatchedEntityError)
    end

    it 'creates a new relationship' do
      expect do
        external_relationship.set_entity(entity1: entity1, entity2: entity2)
      end.to change(Relationship, :count).by(1)
    end

    it 'updates existing relationship' do
      relationship = Relationship.create!(category_id: 1, entity1_id: entity1.id, entity2_id: entity2.id, description1: 'example')
      expect do
        external_relationship.set_entity(entity1: entity1, entity2: entity2)
      end.not_to change(Relationship, :count)
      expect(external_relationship.relationship).to eq relationship
      expect(relationship.reload.description1).to eq "MANAGER/MEMBER"
      expect(relationship.position.is_board).to be true
    end
  end

  # describe 'potential matches' do
  #   describe 'potential_matches_entity1'
  #   describe 'potential_matches_entity2'
  # end
end

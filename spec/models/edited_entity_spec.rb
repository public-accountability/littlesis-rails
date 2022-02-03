# frozen_string_literal: true

describe EditedEntity, type: :model do
  it { is_expected.to have_db_column(:user_id).of_type(:integer) }
  it { is_expected.to have_db_column(:version_id).of_type(:integer) }
  it { is_expected.to have_db_column(:entity_id).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to belong_to(:entity) }
  it { is_expected.to belong_to(:version).optional }
  it { is_expected.to belong_to(:user).optional }
  it { is_expected.to validate_presence_of(:entity_id) }
  it { is_expected.to validate_presence_of(:version_id) }
  it { is_expected.to validate_presence_of(:created_at) }
  it { is_expected.not_to validate_presence_of(:user_id) }

  describe 'unique verison_id/entity_id' do
    let(:entity) { create(:entity_person) }
    let(:version_id) { Faker::Number.unique.number(digits: 8).to_i }

    before do
      EditedEntity.create!(entity_id: entity.id,
                           version_id: version_id,
                           created_at: Faker::Date.backward(days: 100))
    end

    it 'raises error when encouters duplicate version_id/entity_id combo' do
      expect do
        EditedEntity.create!(entity_id: entity.id,
                             version_id: version_id,
                             created_at: Time.current)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'permits creations when version id is different' do
      expect do
        EditedEntity.create!(entity_id: entity.id,
                             version_id: Faker::Number.unique.number(digits: 8).to_i,
                             user_id: rand(10_000),
                             created_at: Time.current)
      end.not_to raise_error
    end

    it 'permits creations when entity id is different' do
      expect do
        EditedEntity.create!(entity_id: create(:entity_person).id,
                             version_id: Faker::Number.unique.number(digits: 8).to_i,
                             created_at: Time.current)
      end.not_to raise_error
    end

  end

  describe 'create_from_verison' do
    let(:entity) { with_versioning { create(:entity_org) }}
    let(:user_id) { Faker::Number.unique.number(digits: 4) }

    let(:relationship) do
      entity1 = create(:entity_org)
      entity2 = create(:entity_person)

      with_versioning do
        PaperTrail.request(whodunnit: user_id) do
          Relationship.create!(entity: entity1, related: entity2, category_id: 12)
        end
      end
    end


    it 'Entity Version: calls EditedEntity.create with correct attributes' do
      version = entity.versions.last

      expect(EditedEntity).to receive(:create)
                                .with({user_id: 1,
                                       version_id: version.id,
                                       entity_id: entity.id,
                                       created_at: version.created_at})
                                .once

      EditedEntity.create_from_version(version)
    end

    it 'Relationship verison: creates two Edited Entities' do
      version = relationship.versions.last
      expect(EditedEntity).to receive(:create)
                                .with({user_id: user_id.to_i,
                                       version_id: version.id,
                                       entity_id: relationship.entity1_id,
                                       created_at: version.created_at})
                                .once

      expect(EditedEntity).to receive(:create)
                                .with({user_id: user_id.to_i,
                                       version_id: version.id,
                                       entity_id: version.entity2_id,
                                       created_at: version.created_at})
                                .once

      EditedEntity.create_from_version(version)
    end
  end

  describe 'populate_table' do
    after do
      EditedEntity.delete_all
    end

    it 'creates 4 edited entities' do
      expect(EditedEntity.count).to eq 0

      with_versioning do
        entity1 = create(:entity_person)
        entity2 = create(:entity_org)
        Relationship.create!(entity: entity1, related: entity2, category_id: 1, description1: 'Position')
      end

      expect(EditedEntity.count).to eq 4
      EditedEntity.delete_all
      EditedEntity.populate_table
      expect(EditedEntity.count).to eq 4
    end
  end
end

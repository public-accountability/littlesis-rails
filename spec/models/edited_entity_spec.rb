# frozen_string_literal: true

require 'rails_helper'

describe EditedEntity, type: :model do
  let(:entity_id) { create(:entity_person, last_user_id: 1).id }
  let(:version_id) { Faker::Number.unique.number(8).to_i }
  let(:user_id) { Faker::Number.unique.number(4).to_i }
  let(:created_at) { Faker::Date.backward(100) }
  let(:org) { create(:entity_org) }
  let(:person) { create(:entity_person) }
  let(:entity_version) { create(:entity_version, item_id: org.id) }
  let(:relationship_version) do
    create(:relationship_version, item_id: org.id, entity1_id: org.id, entity2_id: person.id)
  end

  let(:versions) do
    [entity_version, relationship_version, create(:page_version)]
  end

  it { is_expected.to have_db_column(:user_id).of_type(:integer) }
  it { is_expected.to have_db_column(:version_id).of_type(:integer) }
  it { is_expected.to have_db_column(:entity_id).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to belong_to(:entity) }
  it { is_expected.to belong_to(:version) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:entity_id) }
  it { is_expected.to validate_presence_of(:version_id) }
  it { is_expected.to validate_presence_of(:created_at) }
  it { is_expected.not_to validate_presence_of(:user_id) }

  describe 'unique verison_id/entity_id' do
    before do
      EditedEntity.create!(entity_id: entity_id,
                           version_id: version_id,
                           user_id: user_id,
                           created_at: created_at)
    end

    it 'raises error when encouters duplicate version_id/entity_id combo' do
      expect do
        EditedEntity.create!(entity_id: entity_id,
                             version_id: version_id,
                             user_id: rand(10_000),
                             created_at: Time.current)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'permits creations when version id is different' do
      expect do
        EditedEntity.create!(entity_id: entity_id,
                             version_id: Faker::Number.unique.number(8).to_i,
                             user_id: rand(10_000),
                             created_at: Time.current)
      end.not_to raise_error
    end
  end

  describe 'create_from_verison' do
    it 'Entity Version: calls EditedEntity.create with correct attributes' do
      expect(EditedEntity).to receive(:create)
                                .with(user_id: entity_version.whodunnit.to_i,
                                      version_id: entity_version.id,
                                      entity_id: entity_version.entity1_id,
                                      created_at: entity_version.created_at)
                                .once

      EditedEntity.create_from_version(entity_version)
    end

    it 'Relationship verison: creates two Edited Entities' do
      expect(EditedEntity).to receive(:create)
                                .with(user_id: relationship_version.whodunnit.to_i,
                                      version_id: relationship_version.id,
                                      entity_id: relationship_version.entity1_id,
                                      created_at: relationship_version.created_at)
                                .once

      expect(EditedEntity).to receive(:create)
                                .with(user_id: relationship_version.whodunnit.to_i,
                                      version_id: relationship_version.id,
                                      entity_id: relationship_version.entity2_id,
                                      created_at: relationship_version.created_at)
                                .once

      EditedEntity.create_from_version(relationship_version)
    end
  end

  describe 'populate_table' do
    before do
      versions
      EditedEntity.delete_all
    end

    it 'creates 3 edited entities' do
      expect(EditedEntity.count).to eq 0
      EditedEntity.populate_table
      expect(EditedEntity.count).to eq 3
      EditedEntity.populate_table
      expect(EditedEntity.count).to eq 3
    end
  end

  describe 'recent' do
    before { versions }

    it 'returns 2 entities' do
      expect(EditedEntity.recent.to_a.size).to eq 2
    end

    it 'orders correctly' do
      recently_edited_entities = EditedEntity.recent(page: 1)
      expect(recently_edited_entities[0].entity).to eq org
      expect(recently_edited_entities[1].entity).to eq person
    end

    it 'has correct dates' do
      recently_edited_entities = EditedEntity.recent(page: 1)
      expect(recently_edited_entities[0].created_at).to eq entity_version.created_at
      expect(recently_edited_entities[1].created_at).to eq relationship_version.created_at
    end

    it 'has correct total_count' do
      expect(EditedEntity.recent.total_count).to eq 2
    end
  end
end

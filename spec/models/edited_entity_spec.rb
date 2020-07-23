# frozen_string_literal: true

describe EditedEntity, type: :model do
  let(:entity_id) { create(:entity_person, last_user_id: 1).id }
  let(:version_id) { Faker::Number.unique.number(digits: 8).to_i }
  let(:user_id) { Faker::Number.unique.number(digits: 4).to_i }
  let(:user1_id) { Faker::Number.unique.number(digits: 4).to_i }
  let(:created_at) { Faker::Date.backward(days: 100) }
  let(:org) { create(:entity_org) }
  let(:person) { create(:entity_person) }
  let(:entity_version) { create(:entity_version, item_id: org.id, whodunnit: user_id.to_s) }
  let(:relationship_version) do
    create(:relationship_version, item_id: org.id, entity1_id: org.id, entity2_id: person.id, whodunnit: user1_id.to_s)
  end

  let(:versions) do
    [].tap do |arr|
      arr << entity_version
      sleep 0.01
      arr << relationship_version
      sleep 0.01
      arr << create(:page_version)
    end
    # [entity_version, relationship_version, create(:page_version)]
  end

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
                             version_id: Faker::Number.unique.number(digits: 8).to_i,
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
      expect(EditedEntity.recent.page(1).to_a.size).to eq 2
    end

    it 'has correct dates' do
      recently_edited_entities = EditedEntity.recent.page(1)

      # On travis these values are *sometimes* not exactly equal hence the `within_one_second` hack
      expect(
        within_one_second?(recently_edited_entities[0].created_at, entity_version.created_at)
      ).to be true

      expect(
        within_one_second?(recently_edited_entities[1].created_at, relationship_version.created_at)
      ).to be true
    end

    it 'has correct total_count' do
      expect(EditedEntity.recent.page(1).total_count).to eq 2
    end
  end

  describe 'Query' do
    before { versions }

    describe 'all' do
      specify do
        expect(EditedEntity::Query.all.page(1).length).to eq 2
      end

      specify do
        expect(EditedEntity::Query.all.page(2).length).to eq 0
      end

      specify do
        expect(EditedEntity::Query.all.per(1).page(1).length).to eq 1
      end

      specify do
        expect(EditedEntity::Query.all.per(1).page(3).length).to eq 0
      end
    end

    describe 'for_user' do
      specify do
        expect(EditedEntity::Query.for_user(user_id).page(1).length).to eq 1
      end

      it 'has correct total_count' do
        expect(EditedEntity::Query.for_user(user_id).page(1).total_count).to eq 1
        expect(EditedEntity::Query.for_user(user1_id).page(1).total_count).to eq 2
      end

      specify do
        expect(EditedEntity::Query.for_user(user_id).page(1).first.version).to eq entity_version
      end
    end

    describe 'without_system_users' do
      before do
        create(:entity_version, item_id: create(:entity_org).id, whodunnit: 1)
      end

      specify do
        expect(EditedEntity::Query.all.page(1).length).to eq 3
      end

      specify do
        expect(EditedEntity::Query.without_system_users.page(1).length).to eq 2
      end
    end

    describe 'Entity has been deleted' do
      before do
        with_versioning_for(User.system_user) do
          @entity = create(:entity_person)
        end
      end

      it 'removes deleted entity from results' do
        with_versioning_for(User.system_user) do
          @entity.soft_delete
        end
        expect(EditedEntity::Query.all.page(1).length).to eq 2
      end
    end

    # This might seem like a useless test, but because
    # we use part of Arel's internal api,it's be good
    # detect for changes in future releaes of rails.
    describe 'group_by_entity_id_subquery_for_join' do
      it 'starts with INNER JOIN' do
        expect(EditedEntity.group_by_entity_id_subquery_for_join.slice(0, 10))
          .to eq 'INNER JOIN'
      end
    end
  end
end

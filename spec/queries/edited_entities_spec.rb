# frozen_string_literal: true


describe EditedEntities do
  describe 'initializing with instance vars' do
    it 'sets defaults instance vars' do
      edited_entities = EditedEntities.new
      expect(edited_entities.instance_variable_get(:@per_page)).to eq 20
      expect(edited_entities.instance_variable_get(:@history_limit)).to eq 500
      expect(edited_entities.instance_variable_get(:@user_id)).to be nil
    end

    it 'is overwritten with new vals' do
      edited_entities = EditedEntities.new(user_id: 123, per_page: 10, history_limit: 100)

      expect(edited_entities.instance_variable_get(:@per_page)).to eq 10
      expect(edited_entities.instance_variable_get(:@history_limit)).to eq 100
      expect(edited_entities.instance_variable_get(:@user_id)).to eq 123
    end
  end

  describe 'class methods: all and user' do
    let(:users) { Array.new(2) { create_basic_user } }

    before do
      with_versioning_for(users[0]) { @entity0 = Entity.create!(primary_ext: 'Org', name: 'org') }
      with_versioning_for(users[1]) { @entity1 = Entity.create!(primary_ext: 'Org', name: 'org') }
    end

    describe 'all' do
      it 'finds two entities' do
        edited_entities = EditedEntities.all
        page = edited_entities.page(1)
        expect(page.length).to eq 2
        expect(page.first).to be_a Hash
        expect(page.total_count).to eq 2
        expect(edited_entities.page(2).length).to eq 0
      end

      it 'stores user and entity in hash' do
        page = EditedEntities.all.page(1)
        expect(page.first['entity']).to be_a Entity
        expect(page.first['user']).to eq users[1]
        expect(page.second['user']).to eq users[0]
      end
    end

    describe 'user' do
      it 'user[0]' do
        page = EditedEntities.user(users[0]).page(1)
        expect(page.length).to eq 1
        expect(page.first['entity_id']).to eq @entity0.id
      end

      it 'user[1]' do
        page = EditedEntities.user(users[1]).page(1)
        expect(page.length).to eq 1
        expect(page.first['entity_id']).to eq @entity1.id
      end
    end
  end

  describe 'Relationships and pagination' do
    let(:user) { create_basic_user }
    let(:edited_entities) { EditedEntities.user(user) }

    # User creates one entity and one relationship (with 2 different Orgs)
    before do
      @entity1 = create(:entity_person)
      @entity2 = create(:entity_person)
      with_versioning_for(user) do
        @entity3 = Entity.create!(primary_ext: 'Org', name: 'Corporation')
        Relationship.create!(category_id: 12, entity: @entity1, related: @entity2)
      end
    end

    context 'when per_page is set to 2' do
      it 'returns correct 2 results for page 1' do
        expect(EditedEntities.new(per_page: 2).page(1).length).to eq 2
      end

      it 'returns correct result for page 2' do
        page2 = EditedEntities.new(per_page: 2).page(2)
        expect(page2.length).to eq 1
        expect(page2.first['item_type']).to eq 'Entity'
      end
    end
  end
end

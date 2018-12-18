# frozen_string_literal: true

require 'rails_helper'

describe EditedEntities do
  describe 'self.all' do
    let(:users) { Array.new(2) { create_basic_user } }

    before do
      with_versioning_for(users[0]) { Entity.create!(primary_ext: 'Org', name: 'org') }
      with_versioning_for(users[1]) { Entity.create!(primary_ext: 'Org', name: 'org') }
    end

    it 'finds two entities' do
      edited_entities = EditedEntities.all
      page = edited_entities.page(1)
      expect(page.length).to eq 2
      expect(page.total_count).to eq 2
      expect(edited_entities.page(2).length).to eq 0
      expect(page.first).to be_a Entity
    end
  end

  describe 'initializing with instance vars' do
    it 'sets defaults instance vars' do
      edited_entities = EditedEntities.new
      expect(edited_entities.instance_variable_get(:@per_page)).to eq 20
      expect(edited_entities.instance_variable_get(:@history_limit)).to eq 500
      expect(edited_entities.instance_variable_get(:@where)).to be nil
    end

    it 'is overwritten with new vals' do
      edited_entities = EditedEntities.new(where: { whodunnit: '123' },
                                           per_page: 10,
                                           history_limit: 100)

      expect(edited_entities.instance_variable_get(:@per_page)).to eq 10
      expect(edited_entities.instance_variable_get(:@history_limit)).to eq 100
      expect(edited_entities.instance_variable_get(:@where)).to eq(whodunnit: '123')
    end
  end

  describe 'User' do
    describe '#edited_entities_ids' do
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

      it 'returns array of entity ids' do
        expect(edited_entities.edited_entities_ids.length).to eq 3
        expect(edited_entities.edited_entities_ids).to include(@entity1.id, @entity2.id, @entity3.id)
      end
    end
  end
end

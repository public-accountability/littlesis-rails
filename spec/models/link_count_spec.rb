require 'rails_helper'

describe 'Link Count' do
  describe 'entity#update_link_count' do
    it 'updates link count for entity with no relationships' do
      e = create(:person)
      expect(Entity.find(e.id).link_count).to eq 0
      e.update_link_count
      expect(Entity.find(e.id).link_count).to eq 0
    end

    it 'updates link count after a new relationship is created' do
      e = create(:person)
      expect(Entity.find(e.id).link_count).to eq 0
      Relationship.create!(entity: e, related: create(:person), category_id: 12)
      e.update_link_count
      expect(Entity.find(e.id).link_count).to eq 1
    end
  end

  describe 'after adding a relationship, the link count is changed for both entities' do
    before do
      @entity1 = create(:person)
      @entity2 = create(:person)
      @create_relationship = proc { Relationship.create!(entity: @entity1, related: @entity2, category_id: 12) }
    end

    it "increases entity1's link count" do
      expect(&@create_relationship).to change { Entity.find(@entity1.id).link_count }.by(1)
    end

    it "increases entity2's link count" do
      expect(&@create_relationship).to change { Entity.find(@entity2.id).link_count }.by(1)
    end
  end

  describe 'after removing a relationship, the link count is decreased for both entities' do
    before do
      @entity1 = create(:person)
      @entity2 = create(:person)
      @rel = Relationship.create!(entity: @entity1, related: @entity2, category_id: 12)
    end

    it "decreases entity1's link count" do
      expect { @rel.soft_delete }
        .to change { Entity.find(@entity1.id).link_count }.by(-1)
    end

    it "decreases entity2's link count" do
      expect { @rel.soft_delete }
        .to change { Entity.find(@entity2.id).link_count }.by(-1)
    end
  end
end

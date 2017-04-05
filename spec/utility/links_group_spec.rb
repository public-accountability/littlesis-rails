require 'rails_helper'

describe LinksGroup do
  context 'with generic links' do
    before  do
      rel1 = build(:generic_relationship, entity1_id: 10, entity2_id: 20)
      rel2 = build(:generic_relationship, entity1_id: 10, entity2_id: 50)
      @link1 = build(:link, entity1_id: 10, entity2_id: 20, relationship: rel1, category_id: 12)
      @link2 = build(:link, entity1_id: 10, entity2_id: 50, relationship: rel2, category_id: 12)
      @links_group = LinksGroup.new([@link1, @link2], 'miscellaneous', 'Other Affiliations')
    end

    it 'sets keybord, heading and category_id' do
      expect(@links_group.keyword).to eq 'miscellaneous'
      expect(@links_group.heading).to eq 'Other Affiliations'
      expect(@links_group.category_id).to eq 12
    end

    it 'has correct count' do
      expect(@links_group.count).to eq 2
    end

    it 'links is a nested array' do
      expect(@links_group.links).to be_a(Array)
      expect(@links_group.links[0]).to be_a(Array)
      expect(@links_group.links[0][0]).to be_a(Link)
    end

    it 'orders the data in the default order' do
      expect(@links_group.links).to eq [[@link1], [@link2]]
    end
  end
  
  context 'with donation links' do
    before do
      e1_id = 1000
      rel1 = build(:donation_relationship, entity1_id: e1_id, entity2_id: 2000, amount: 10)
      rel2 = build(:donation_relationship, entity1_id: e1_id, entity2_id: 3000, amount: 30)
      rel3 = build(:donation_relationship, entity1_id: e1_id, entity2_id: 3000, amount: 20)
      @link1 = build(:link, entity1_id: e1_id, entity2_id: 2000, relationship: rel1, category_id: 5)
      @link2 = build(:link, entity1_id: e1_id, entity2_id: 3000, relationship: rel2, category_id: 5)
      @link3 = build(:link, entity1_id: e1_id, entity2_id: 3000, relationship: rel3, category_id: 5)
      @links_group = LinksGroup.new([@link1, @link2, @link3],  'donation_recipients', 'Donation/Grant Recipients')
    end

    it 'has correct count' do
      expect(@links_group.count).to eq 2
    end

    it 'order links by amount' do
      expect(@links_group.links).to eq [[@link2,@link3], [@link1]]
    end
  end
end

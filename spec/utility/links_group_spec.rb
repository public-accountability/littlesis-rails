require 'rails_helper'

describe LinksGroup do
  context 'generic links' do
    before  do
      rel1 = build(:generic_relationship, entity1_id: 10, entity2_id: 20)
      rel2 = build(:generic_relationship, entity1_id: 10, entity2_id: 50)
      @link1 = build(:link, entity1_id: 10, entity2_id: 20, relationship: rel1, category_id: 12)
      @link2 = build(:link, entity1_id: 10, entity2_id: 50, relationship: rel2, category_id: 12)
      @links_group = LinksGroup.new([@link1, @link2], 'miscellaneous', 'Other Affiliations')
    end

    describe 'initalize' do
      it 'sets keybord, heading and category_id' do
        expect(@links_group.keyword).to eq 'miscellaneous'
        expect(@links_group.heading).to eq 'Other Affiliations'
        expect(@links_group.category_id).to eq 12
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

  end 
end

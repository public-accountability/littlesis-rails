require 'rails_helper'

describe SortedLinks do

  describe 'Initialize' do
    it 'requires an Entity as the first argument' do
      org = build(:org)
      expect { SortedLinks.new(org) }.not_to raise_error
      expect { SortedLinks.new('123') }.to raise_error(ArgumentError)
    end

    it 'sets @entity' do
      org = build(:org)
      sorted_links = SortedLinks.new(org)
      expect(sorted_links.instance_variable_get('@entity')).to eq org
    end
  end

  describe '#get_other_positions_and_memberships_heading' do
    before do
      @sorted_links = SortedLinks.new(build(:org))
    end

    it 'returns "Memberships" if other_positions_count is zero' do
      expect(@sorted_links.get_other_positions_and_memberships_heading(0, 0, 0)).to eq 'Memberships'
      expect(@sorted_links.get_other_positions_and_memberships_heading(100, 0, 0)).to eq 'Memberships'
      expect(@sorted_links.get_other_positions_and_memberships_heading(0, 0, 100)).to eq 'Memberships'
    end

    context 'membership count is 0' do
      it 'returns "Positions" if other_positions_count equals positions_count' do
        expect(@sorted_links.get_other_positions_and_memberships_heading(1, 1, 0)).to eq 'Positions'
      end

      it 'returns "Other Positions" if the counts are different' do
        expect(@sorted_links.get_other_positions_and_memberships_heading(1, 2, 0)).to eq 'Other Positions'
        expect(@sorted_links.get_other_positions_and_memberships_heading(2, 1, 0)).to eq 'Other Positions'
      end
    end

    it 'returns "positions & Memberships" if other_positions equals positions and membership is not zero' do
      expect(@sorted_links.get_other_positions_and_memberships_heading(2, 2, 1)).to eq 'Positions & Memberships'
      expect(@sorted_links.get_other_positions_and_memberships_heading(2, 2, 0)).not_to eq 'Positions & Memberships'
    end

    it 'returns "Other Positions & Memberships" if other positions and positions are equal' do
      expect(@sorted_links.get_other_positions_and_memberships_heading(1, 2, 1)).to eq 'Other Positions & Memberships'
      expect(@sorted_links.get_other_positions_and_memberships_heading(2, 1, 1)).to eq 'Other Positions & Memberships'
    end

  end

  context 'initalized with a section' do
    let(:org_with_members) { create(:entity_org) }
    let(:org_with_membership) { create(:entity_org) }

    before do
      create(:generic_relationship, entity: org_with_members, related: create(:entity_person))
      create(:membership_relationship, entity: org_with_membership, related: org_with_members)
    end

    it 'returns LinksGroup with members relationship' do
      links_group = SortedLinks.new(org_with_members, 'members', 1).members
      expect(links_group.count).to eq 1
    end

    it 'returns LinksGroup with memberships relationship' do
      links_group = SortedLinks.new(org_with_membership, 'memberships', 1).memberships
      expect(links_group.count).to eq 1
    end

    describe '#preloaded_links_for_section' do
      it 'returns preloaded Links with members relationships' do
        sorted_links = SortedLinks.new(org_with_members, 'members', 1)
        preloaded_links = sorted_links.send(:preloaded_links_for_section, org_with_members.id, 'members')
        expect(preloaded_links.length).to eql 1
        expect(preloaded_links.first).to be_a Link
      end
    end
  end
end

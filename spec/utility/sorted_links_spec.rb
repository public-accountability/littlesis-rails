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

  describe 'Position sorted' do
    let(:government) { create(:entity_org).add_extension('GovernmentBody') }
    let(:business) { create(:entity_org).add_extension('Business') }
    let(:person) { create(:entity_person, :with_person_name) }

    subject { SortedLinks.new(person) }

    context 'with one business relationship and one government relationships' do
      before do
        Relationship.create!(category_id: RelationshipCategory.name_to_id[:position], entity: person, related: government)
        Relationship.create!(category_id: RelationshipCategory.name_to_id[:position], entity: person, related: business)
      end

      it 'has one business_position' do
        expect(subject.business_positions).to be_a LinksGroup
        expect(subject.business_positions.count).to eql 1
      end

      it 'has one governnment_position' do
        expect(subject.government_positions).to be_a LinksGroup
        expect(subject.government_positions.count).to eql 1
      end

      it 'has NO in the office of positions or other positions' do
        expect(subject.in_the_office_positions.count).to be_zero 
        expect(subject.other_positions.count).to be_zero
      end
    end

    context 'with one business position and one other position' do
      before do
        Relationship.create!(category_id: RelationshipCategory.name_to_id[:position], entity: person, related: create(:entity_org))
        Relationship.create!(category_id: RelationshipCategory.name_to_id[:position], entity: person, related: business)
      end

      it 'has one business_position' do
        expect(subject.business_positions).to be_a LinksGroup
        expect(subject.business_positions.count).to eql 1
      end

      it 'has one other position with heading "Other positions"' do
        expect(subject.other_positions.count).to eql 1
        expect(subject.other_positions.heading).to eql 'Other Positions'
      end

      it 'has NO in the office of positions or government  positions' do
        expect(subject.in_the_office_positions.count).to be_zero
        expect(subject.government_positions.count).to be_zero
      end
    end

    context 'with two other positions' do
      before do
        Relationship.create!(category_id: RelationshipCategory.name_to_id[:position], entity: person, related: create(:entity_org))
        Relationship.create!(category_id: RelationshipCategory.name_to_id[:position], entity: person, related: create(:entity_org))
      end

      it 'has two other positions with heading "Positions"' do
        expect(subject.other_positions.count).to eql 2
        expect(subject.other_positions.heading).to eql 'Positions'
      end

      it 'has NO in the office positions, government positions, or business positions' do
        expect(subject.in_the_office_positions.count).to be_zero
        expect(subject.government_positions.count).to be_zero
          expect(subject.business_positions.count).to be_zero
      end
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

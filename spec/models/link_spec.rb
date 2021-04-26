describe Link, type: :model do
  it { is_expected.to belong_to(:relationship) }
  it { is_expected.to belong_to(:entity) }
  it { is_expected.to belong_to(:related) }
  it { is_expected.to have_many(:chained_links) }

  def org_with_type(type)
    org = create(:entity_org)
    org.add_extension(type)
    org
  end

  def person_with_type(type)
    person = create(:entity_person)
    person.add_extension(type)
    person
  end

  describe 'relationship_network_for' do
    let(:root) { create(:entity_person) }
    let(:entities) do
      {
        'a' => create(:entity_org, name: 'a'),
        'b' => create(:entity_org, name: 'b'),
        'c' => create(:entity_org, name: 'c'),
        'd' => create(:entity_org, name: 'd'),
        'x' => create(:entity_org, name: 'x'),
        'y' => create(:entity_org, name: 'y')
      }
    end

    let!(:root_to_a) { create(:relationship, entity: root, related: entities['a'], category_id: 1) }
    let!(:b_to_root) { create(:relationship, entity: entities['b'], related: root, category_id: 12) }

    before do
      create(:relationship, entity: entities['a'], related: entities['c'], category_id: 3)
      create(:relationship, entity: entities['a'], related: entities['d'], category_id: 5)
      create(:relationship, entity: entities['b'], related: entities['d'], category_id: 5)
      create(:relationship, entity: entities['x'], related: entities['y'], category_id: 12)
      create(:relationship, entity: entities['c'], related: create(:entity_person), category_id: 12)
    end

    context 'when looking at the network for a root node' do
      let(:network) { Link.relationship_network_for(root) }

      it 'returns 5 hashes' do
        expect(network.count).to eq 5
      end

      it 'reverses relationship order if needed' do
        expect(network.find { |h| h['category_id'] == 1 })
          .to include({ id: root_to_a.id, category_id: 1, entity1_id: root.id, entity2_id: entities['a'].id }.stringify_keys)

        expect(network.find { |h| h['category_id'] == 12 })
          .to include({ id: b_to_root.id, category_id: 12, entity1_id: entities['b'].id, entity2_id: root.id }.stringify_keys)
      end
    end

    context 'with a network for 2 entities' do
      let(:network) { Link.relationship_network_for([root, entities['x']]) }

      it 'returns 6 hashes' do
        expect(network.count).to eq 6
      end
    end
  end

  describe '#position_type' do
    it 'returns "none" for non-position relationships' do
      expect(build(:link, category_id: 2).position_type).to eq 'None'
      expect(build(:link, category_id: 3).position_type).to eq 'None'
      expect(build(:link, category_id: 12).position_type).to eq 'None'
    end

    it 'returns business if other entity is a Business' do
      org = org_with_type('Business')
      link = build(:link, category_id: 1, entity2_id: org.id)
      expect(link.position_type).to eq 'business'
    end

    it 'returns office if other entity is a businessPerson' do
      person = person_with_type('BusinessPerson')
      link = build(:link, category_id: 1, entity2_id: person.id)
      expect(link.position_type).to eq 'office'
    end

    it 'returns government if other entity is a gov' do
      org = org_with_type('GovernmentBody')
      link = build(:link, category_id: 1, entity2_id: org.id)
      expect(link.position_type).to eq 'government'
    end

    it 'returns office if other entity is a PublicOfficial' do
      person = person_with_type('PublicOfficial')
      link = build(:link, category_id: 1, entity2_id: person.id)
      expect(link.position_type).to eq 'office'
    end

    it 'returns office if other entity is a elected' do
      person = person_with_type('ElectedRepresentative')
      link = build(:link, category_id: 1, entity2_id: person.id)
      expect(link.position_type).to eq 'office'
    end

    it 'returns "other" if entity is sothing else' do
      org = org_with_type('LaborUnion')
      link = build(:link, category_id: 1, entity2_id: org.id)
      expect(link.position_type).to eq 'other'
    end
  end

  describe '#link_content' do
    let(:person) { create(:entity_person) }
    let(:company) { create(:public_company_entity) }
    let(:relationship) do
      create(:ownership_relationship, entity: person, related: company, notes: "Some text",
                                      start_date: "2004-01-03", end_date: "2016-05-07")
    end

    let!(:ownership) { create(:ownership, relationship: relationship, percent_stake: 100) }
    let!(:link) { relationship.link }

    it 'describes the relationship' do
      expect(link.link_content).to include('Owner')
    end

    it 'shows percent stake for ownership if present' do
      expect(link.link_content).to include('; percent stake: 100%')
      ownership.update!(percent_stake: 0)
      expect(link.reload.link_content).not_to include('percent stake')
    end

    it 'signals notes with an asterisk if present' do
      expect(link.link_content).to include('*')
      relationship.update!(notes: "")
      expect(link.link_content).not_to include('*')
    end

    it 'shows date range if present' do
      expect(link.link_content).to include("(Jan 3 '04→May 7 '16)")
      relationship.update!(end_date: nil)
      expect(link.link_content).to include("(Jan 3 '04→?)")
      relationship.update!(start_date: nil)
      expect(link.link_content).not_to include("('")
    end
  end

  describe '.populated?' do
    context 'with a relationship' do
      before do
        create(:relationship, entity: create(:entity_person), related: create(:entity_person), category_id: 1)
      end

      scenario 'the links view is automatically populated' do
        expect(Relationship.count).to eq 1
        expect(Link.populated?).to be true
      end
    end
  end
end

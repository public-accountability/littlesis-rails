require 'rspec-benchmark'

describe Link, type: :model do
  include RSpec::Benchmark::Matchers

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

  describe 'Subcategory'do
    specify 'businesses' do
      relationship = Relationship.create!(category_id: 1, entity: create(:entity_person), related: create(:public_company_entity))
      expect(relationship.link.subcategory).to eq 'businesses'
      expect(relationship.reverse_link.subcategory).to eq 'staff'
    end

    specify 'government' do
      relationship = Relationship.create!(category_id: 1, entity: create(:entity_person), related: create(:government_entity))
      expect(relationship.link.subcategory).to eq 'governments'
      expect(relationship.reverse_link.subcategory).to eq 'staff'
    end


    specify 'offices' do
      relationship = Relationship.create!(category_id: 1, entity: create(:entity_person), related: create(:entity_person))
      expect(relationship.link.subcategory).to eq 'offices'
      expect(relationship.reverse_link.subcategory).to eq 'staff'
    end

    specify 'staff' do
      relationship = Relationship.create!(category_id: 1, entity: create(:entity_person), related: create(:entity_org))
      expect(relationship.link.subcategory).to eq 'positions'
      expect(relationship.reverse_link.subcategory).to eq 'staff'
    end

    specify 'board memberships' do
      relationship = Relationship.create!(category_id: 1, entity: create(:entity_person), related: create(:entity_org))
      expect(relationship.link.subcategory).to eq 'positions'
      relationship.position.update!(is_board: true)
      expect(relationship.link.subcategory).to eq 'board_memberships'
      expect(relationship.reverse_link.subcategory).to eq 'board_members'
    end

    specify 'education' do
      relationship = Relationship.create!(category_id: Relationship::EDUCATION_CATEGORY, entity: create(:entity_person), related: create(:entity_org))
      expect(relationship.link.subcategory).to eq 'schools'
      expect(relationship.reverse_link.subcategory).to eq 'students'
    end

    specify 'membership' do
      relationship = Relationship.create!(category_id: Relationship::MEMBERSHIP_CATEGORY, entity: create(:entity_org), related: create(:entity_org))
      expect(relationship.link.subcategory).to eq 'memberships'
      expect(relationship.reverse_link.subcategory).to eq 'members'
    end

    specify 'family' do
      relationship = Relationship.create!(category_id: Relationship::FAMILY_CATEGORY, entity: create(:entity_person), related: create(:entity_person))
      expect(relationship.link.subcategory).to eq 'family'
      expect(relationship.reverse_link.subcategory).to eq 'family'
    end

    specify 'fec donation relationship' do
      relationship = Relationship.create!(category_id: 5, entity: create(:entity_person), related: create(:entity_org), filings: 2, amount: 1000, description1: 'Campaign Contribution')
      expect(relationship.link.subcategory).to eq 'campaign_contributions'
      expect(relationship.reverse_link.subcategory).to eq 'campaign_contributors'
    end

    specify 'donation relationship' do
      relationship = Relationship.create!(category_id: 5, entity: create(:entity_person), related: create(:entity_org))
      expect(relationship.link.subcategory).to eq 'donations'
      expect(relationship.reverse_link.subcategory).to eq 'donors'
    end

    specify 'transaction' do
      relationship = Relationship.create!(category_id: 6, entity: create(:entity_person), related: create(:entity_org))
      expect(relationship.link.subcategory).to eq 'transactions'
      expect(relationship.reverse_link.subcategory).to eq 'transactions'
    end

    specify 'lobbying' do
      relationship = Relationship.create!(category_id: Relationship::LOBBYING_CATEGORY, entity: create(:entity_person), related: create(:entity_org))
      expect(relationship.link.subcategory).to eq 'lobbies'
      expect(relationship.reverse_link.subcategory).to eq 'lobbied_by'
    end

    specify 'professional & social' do
      entity1 = create(:entity_person)
      entity2 = create(:entity_person)
      social_relationship = Relationship.create!(category_id: Relationship::SOCIAL_CATEGORY, entity: entity1, related: entity2)
      professional_relationship = Relationship.create!(category_id: Relationship::PROFESSIONAL_CATEGORY, entity: entity1, related: entity2)
      (social_relationship.links + professional_relationship.links).each do |link|
        expect(link.subcategory).to eq 'social'
      end
    end

    specify 'ownership' do
      relationship = Relationship.create!(category_id: 10, entity: create(:entity_org), related: create(:entity_org))
      expect(relationship.link.subcategory).to eq 'holdings'
      expect(relationship.reverse_link.subcategory).to eq 'owners'
    end

    specify 'hierarchy' do
      relationship = Relationship.create!(category_id: 11, entity: create(:entity_org), related: create(:entity_org))
      expect(relationship.link.subcategory).to eq 'parents'
      expect(relationship.reverse_link.subcategory).to eq 'children'
    end

    specify 'generic' do
      relationship = Relationship.create!(category_id: 12, entity: create(:entity_person), related: create(:entity_person))
      expect(relationship.links[0].subcategory).to eq 'generic'
      expect(relationship.links[1].subcategory).to eq 'generic'
    end
  end
end

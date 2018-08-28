require 'rails_helper'

describe Link, type: :model do
  it { should belong_to(:relationship) }
  it { should belong_to(:entity) }
  it { should belong_to(:related) }
  it { should have_many(:chained_links) }

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

  # cr = create_relationship
  def cr(entity, related, cat)
    Relationship.create!(category_id: cat, entity: entity, related: related)
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

    # root is connected to a and b
    # a is connected to c and d
    # b is connected to d
    before do
      @position_relationship = cr(root, entities['a'], 1)
      @generic_relationship = cr(entities['b'], root, 12)
      cr entities['a'], entities['c'], 3
      cr entities['a'], entities['d'], 5
      cr entities['b'], entities['d'], 5
      # relationships between x & y
      cr entities['x'], entities['y'], 12
      # random relationship
      cr entities['c'], create(:entity_person), 12
    end

    context 'network for root node' do
      subject { Link.relationship_network_for(root) }

      it 'returns 5 hashes' do
        expect(subject.count).to eql 5
      end

      it 'reverses relationship order if needed' do
        expect(subject.find { |h| h['category_id'] == 1 })
          .to eql({ 'id' => @position_relationship.id,
                    'category_id' => 1,
                    'entity1_id' => root.id,
                    'entity2_id' => entities['a'].id })

        expect(subject.find { |h| h['category_id'] == 12 })
          .to eql({ 'id' => @generic_relationship.id,
                    'category_id' => 12,
                    'entity1_id' => entities['b'].id,
                    'entity2_id' =>  root.id })
      end
    end

    context 'network for 2 entities' do
      subject { Link.relationship_network_for([root, entities['x']]) }

      it 'returns 6 hashes' do
        expect(subject.count).to eql 6
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
end

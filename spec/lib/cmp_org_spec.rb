require "rails_helper"

describe Cmp::CmpOrg do
  let(:attributes) do
    {
      cmpid: Faker::Number.number(6),
      cmpname: 'big oil inc',
      cmpmnemonic: 'big oil',
      website: 'http://oil.com',
      city: 'Vancouver',
      ticker: 'BO'
    }
  end
  subject { Cmp::CmpOrg.new(attributes) }
  let(:org) { create(:entity_org) }

  describe 'find_or_create_entity' do
    context 'cmp entity already exists' do
      before do
        create(:cmp_entity, entity: org, entity_type: :org, cmp_id: attributes.fetch(:cmpid))
      end

      it 'returns the already existing entity' do
        expect(subject.find_or_create_entity).to eql org
      end
    end

    context 'found a matched entity' do
      let(:org) { build(:org) }
      before do
        entity_match = double('EntityMatch')
        expect(entity_match).to receive(:empty?).and_return(false)
        expect(entity_match).to receive(:match).and_return(org)
        subject.instance_variable_set(:@_entity_match, entity_match)
      end

      it 'returns matched entity' do
        expect(subject.find_or_create_entity).to eql org
      end
    end

    context 'need to create a new entity' do
      before do
        expect(subject).to receive(:entity_match).and_return(double(:empty? => true))
      end
      it 'creates a new entity' do
        expect { subject.find_or_create_entity }.to change { Entity.count }.by(1)
        expect(Entity.last.name).to eql attributes[:cmpname]
      end
    end
  end

  describe 'helper methods' do
    describe '#attrs_for' do
      let(:attributes) { { website: 'http://example.com', city: 'new york' } }
      subject { Cmp::CmpOrg.new(attributes) }

      it 'extracts attributes for given model' do
        expect(subject.send(:attrs_for, :entity))
          .to eql(website: 'http://example.com')

        expect(subject.send(:attrs_for, :address))
          .to eql(city: 'new york', latitude: nil, longitude: nil)
      end
    end
  end
end

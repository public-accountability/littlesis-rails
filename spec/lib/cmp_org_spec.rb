require "rails_helper"

describe Cmp::CmpOrg do
  let(:org) { create(:entity_org) }

  let(:attributes) do
    {
      cmpid: Faker::Number.number(6),
      cmpname: 'big oil inc',
      cmpmnemonic: Faker::Company.name,
      website: 'http://oil.com',
      city: 'Vancouver',
      country: 'Canada'
    }
  end
  subject { Cmp::CmpOrg.new(attributes) }

  describe 'import!' do
    before do
      expect(subject).to receive(:entity_match).and_return(double(:empty? => true))
    end

    context 'Entity is not already in the database' do
      it 'creates a new entity' do
        expect { subject.import! }.to change { Entity.count }.by(1)
      end

      it 'creates a cmp entity' do
        expect { subject.import! }.to change { CmpEntity.count }.by(1)
        expect(CmpEntity.last.attributes.fetch('cmp_id'))
          .to eql attributes.fetch(:cmpid).to_i
      end

      it 'updates fields name_nick' do
        expect { subject.import! }.to change { Org.count }.by(1)
        expect(Org.last.name_nick).to eql attributes.fetch(:cmpmnemonic)
        expect(Org.last.revenue).to be_nil
      end

      it 'creates a new address' do
        expect { subject.import! }.to change { Address.count }.by(1)
        expect(Address.last.city).to eql attributes.fetch(:city)
      end
    end

    context 'entity has revenue fields' do
      let(:revenue) { rand(10_000) }
      subject { Cmp::CmpOrg.new(attributes.merge(revenue: revenue)) }

      it 'updates org field: name_nick' do
        expect { subject.import! }.to change { Org.count }.by(1)
        expect(Org.last.name_nick).to eql attributes.fetch(:cmpmnemonic)
      end

      it 'updates org field: revenue' do
        subject.import!
        expect(Org.last.revenue).to eql revenue
      end

      it 'does not create a public company' do
        expect { subject.import! }.not_to change { PublicCompany.count }
      end
    end

    context 'entity has ticker' do
      let(:ticker) { ('a'..'z').to_a.sample(3).join }
      subject { Cmp::CmpOrg.new(attributes.merge(ticker: ticker)) }

      it 'creates and updates the public company' do
        expect { subject.import! }.to change { PublicCompany.count }.by(1)
        expect(PublicCompany.last.ticker).to eql ticker
      end
    end
  end

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
      let(:attributes) { { website: 'http://example.com', city: 'new york', country: 'USA' } }
      subject { Cmp::CmpOrg.new(attributes) }

      it 'extracts attributes for given model' do
        expect(subject.send(:attrs_for, :entity))
          .to eql('website' => 'http://example.com')

        expect(subject.send(:attrs_for, :address))
          .to eql(LsHash.new(city: 'new york', latitude: nil, longitude: nil, country_name: 'USA'))
      end
    end
  end
end

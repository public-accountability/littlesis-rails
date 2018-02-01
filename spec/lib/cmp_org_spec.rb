require "rails_helper"

describe Cmp::CmpOrg do
  let(:org) { create(:entity_org) }
  let(:override) { {} }
  let(:attributes) do
    {
      cmpid: Faker::Number.number(6),
      cmpname: 'big oil inc',
      cmpmnemonic: Faker::Company.name,
      website: 'http://oil.com',
      city: 'Vancouver',
      country: 'Canada',
      orgtype_code: '9'
    }
  end

  subject { Cmp::CmpOrg.new(attributes.merge(override)) }

  describe 'import!' do
    context 'Entity is not already in the database' do
      before do
        expect(subject).to receive(:entity_match).and_return(double(:has_match? => false))
      end

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

      it 'creates an extension' do
        expect { subject.import! }.to change { Business.count }.by(1)
      end

      context 'entity is a research institute' do
        before do
          allow(subject).to receive(:entity_match).and_return(double(:has_match? => false))
          subject.import!
        end

        it 'creates the extension while updating' do
          expect(Entity.last.has_extension?('ResearchInstitute')).to be false
          expect do
            Cmp::CmpOrg.new(attributes.merge(orgtype_code: '5')).import!
          end.not_to change { Entity.count }
          expect(Entity.last.has_extension?('ResearchInstitute')).to be true
        end
      end

      context 'entity has revenue fields' do
        let(:revenue) { rand(10_000) }
        let(:override) { { revenue: revenue } }
        # subject { Cmp::CmpOrg.new(attributes.merge(revenue: revenue)) }

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
        let(:override) { { ticker: ticker } }

        it 'creates and updates the public company' do
          expect { subject.import! }.to change { PublicCompany.count }.by(1)
          expect(PublicCompany.last.ticker).to eql ticker
        end
      end
    end

    context 'entity has already been imported, but a field has changed' do
      before do
        allow(subject).to receive(:entity_match).and_return(double(:has_match? => false))
        subject.import!
      end

      specify do
        expect do
          Cmp::CmpOrg.new(attributes.merge(website: Faker::Internet.url)).import!
        end.not_to change { CmpEntity.count }
      end

      specify do
        expect do
          Cmp::CmpOrg.new(attributes.merge(website: Faker::Internet.url)).import!
        end.not_to change { Entity.count }
      end

      it 'updates entity field' do
        new_website = Faker::Internet.url
        expect(Entity.last.website).to eql attributes.fetch(:website)
        Cmp::CmpOrg.new(attributes.merge(website: new_website)).import!
        expect(Entity.last.website).to eql new_website
      end
    end

    context 'matched entity already has a CmpEntity' do
      let(:entity) { create(:entity_org) }
      before do
        CmpEntity.create!(cmp_id: Faker::Number.number(6), entity_id: entity.id, entity_type: :org)
        expect(subject).to receive(:entity_match).and_return(double(:has_match? => true))
        expect(subject).to receive(:entity_match).twice.and_return(double(:match => entity))
        # expect(subject).to receive(:find_or_create_entity).and_return(CmpEntity.last.entity)
      end

      it 'does not create a new CmpEntity' do
        expect { subject.import! }.not_to change { CmpEntity.count }
      end
    end
  end

  describe 'initialization' do
    it 'sets @org_type' do
      expect(subject.org_type).to be_a Cmp::OrgType
    end

    context 'has assets_2015' do
      let(:override) { { assets_2016: nil, assets_2015: 5, assets_2014: nil } }
      specify { expect(subject.fetch(:assets)).to eql 5 }
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
      let(:org) { build(:org, id: rand(10_000)) }
      before do
        entity_match = double('EntityMatch')
        expect(entity_match).to receive(:has_match?).and_return(true)
        expect(entity_match).to receive(:match).twice.and_return(org)
        subject.instance_variable_set(:@_entity_match, entity_match)
      end

      it 'returns matched entity' do
        expect(subject.find_or_create_entity).to eql org
      end
    end

    context 'need to create a new entity' do
      before do
        expect(subject).to receive(:entity_match).and_return(double(:has_match? => false))
      end
      it 'creates a new entity' do
        expect { subject.find_or_create_entity }.to change { Entity.count }.by(1)
        expect(Entity.last.name).to eql attributes[:cmpname]
      end
    end
  end

  describe 'helper methods' do
    describe '#attrs_for' do
      let(:attributes) do
        { website: 'http://example.com', city: 'new york', country: 'USA', orgtype_code: 9 }
      end
      subject { Cmp::CmpOrg.new(attributes) }

      it 'extracts attributes for given model' do
        expect(subject.send(:attrs_for, :entity))
          .to eql('website' => 'http://example.com', 'is_current' => nil)

        expect(subject.send(:attrs_for, :address))
          .to eql(LsHash.new(city: 'new york', latitude: nil, longitude: nil, country_name: 'USA'))
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe ExternalDatasetService do
  describe 'base' do
    it 'requires external_dataset' do
      expect { ExternalDatasetService::Base.new }.to raise_error(ArgumentError)
      expect { ExternalDatasetService::Base.new(external_dataset: {}) }.to raise_error(TypeError)
    end

    it 'sets entity if provided' do
      entity = build(:entity_person)
      service = ExternalDatasetService::Base.new(external_dataset: build(:external_dataset), entity: entity)
      expect(service.entity).to eql entity
    end

    it 'sets entity if external_dataset is matched' do
      entity = instance_double('Entity')
      ed = instance_double('ExternalDataset', :entity => entity, :matched? => true)
      allow(ed).to receive(:is_a?).with(ExternalDataset).and_return(true)
      service = ExternalDatasetService::Base.new(external_dataset: ed)
      expect(service.entity).to eq entity
    end

    it 'does not set entity if external_dataset is not matched' do
      ed = instance_double('ExternalDataset', :matched? => false)
      allow(ed).to receive(:is_a?).with(ExternalDataset).and_return(true)
      service = ExternalDatasetService::Base.new(external_dataset: ed)
      expect(service.entity).to be nil
    end
  end

  describe 'crd_number?' do
    it 'returns false for blank strings' do
      expect(ExternalDatasetService::Iapd.crd_number?('')).to be false
    end

    it 'returns false for spring with "-"' do
      not_a_crd_number = '23-2696041'
      expect(ExternalDatasetService::Iapd.crd_number?(not_a_crd_number)).to be false
    end

    it 'returns false for random strings' do
      expect(ExternalDatasetService::Iapd.crd_number?('foobar')).to be false
    end

    it 'returns true for integers' do
      expect(ExternalDatasetService::Iapd.crd_number?('2786221')).to be true
    end
  end

  describe 'class methods: validate_match!, match, unmatch' do
    let(:external_dataset) { build(:external_dataset) }
    let(:entity) { build(:entity_person) }
    let(:iapd_service) { instance_spy('ExternalDatasetService::Iapd') }

    it 'calls validate_match! on correct dataset subclass' do
      expect(ExternalDatasetService::Iapd)
        .to receive(:new).once
              .with(external_dataset: external_dataset, entity: entity)
              .and_return(iapd_service)

      ExternalDatasetService.validate_match!(external_dataset: external_dataset, entity: entity)
      expect(iapd_service).to have_received(:validate_match!).once
    end

    it 'calls match on correct dataset subclass' do
      expect(ExternalDatasetService::Iapd)
        .to receive(:new).once
              .with(external_dataset: external_dataset, entity: entity)
              .and_return(iapd_service)

      ExternalDatasetService.match(external_dataset: external_dataset, entity: entity)
      expect(iapd_service).to have_received(:match).once
    end

    it 'calls unmatch on correct dataset subclass' do
      expect(ExternalDatasetService::Iapd)
        .to receive(:new).once
              .with(external_dataset: external_dataset)
              .and_return(iapd_service)

      ExternalDatasetService.unmatch(external_dataset: external_dataset)
      expect(iapd_service).to have_received(:unmatch).once
    end
  end

  describe 'Iapd' do
    let(:external_dataset_owner) { build(:external_dataset_iapd_owner) }
    let(:external_dataset_advisor) { build(:external_dataset_iapd_advisor) }
    let(:crd_number) { Faker::Number.unique.number(5).to_i }

    describe '#validate_match!' do
      let(:person) { create(:entity_person) }
      let(:org) { create(:entity_org) }
      let(:service_person) { ExternalDatasetService::Iapd.new(entity: person, external_dataset: external_dataset_owner) }
      let(:service_org) { ExternalDatasetService::Iapd.new(entity: org, external_dataset: external_dataset_advisor) }

      it 'raises error if person has crd number' do
        person.add_extension('BusinessPerson', crd_number: crd_number)
        expect { service_person.validate_match! }.to raise_error(ExternalDatasetService::InvalidMatchError)
      end

      it 'rasies error if org has a crd number' do
        org.add_extension('Business', crd_number: crd_number)
        expect { service_org.validate_match! }.to raise_error(ExternalDatasetService::InvalidMatchError)
      end

      it 'ok if business does not have a crd number' do
        org.add_extension('Business')
        expect { service_org.validate_match! }.not_to raise_error
      end

      it 'ok if person does not have a crd number' do
        person
        expect { service_person.validate_match! }.not_to raise_error
      end

      it 'raises error if another entity already has crd number'
    end

    describe 'match' do
      let(:person) { create(:entity_person) }
      let(:org) { create(:entity_org) }

      context 'with owner key that is not a crd number' do
        let(:external_dataset) { create(:external_dataset_iapd_owner_without_crd) }
        let(:service) { ExternalDatasetService::Iapd.new(entity: person, external_dataset: external_dataset) }

        it 'add entity_id to external_dataset' do
          expect { service.match }
            .to change { external_dataset.reload.entity_id }
                  .from(nil).to(person.id)
        end

        it 'creates business person' do
          expect { service.match }.to change(BusinessPerson, :count).by(1)
        end

        it 'does not set crd_number' do
          expect(person.business_person).to be nil
          service.match
          expect(person.reload.business_person.crd_number).to be nil
        end
      end

      context 'with owner key that is a crd number' do
        let(:external_dataset) { create(:external_dataset_iapd_owner) }
        let(:service) { ExternalDatasetService::Iapd.new(entity: person, external_dataset: external_dataset) }

        it 'creates business person' do
          expect { service.match }.to change(BusinessPerson, :count).by(1)
        end

        it 'add crd number to business person' do
          expect(person.business_person).to be nil
          service.match
          expect(person.reload.business_person.crd_number).to eq 7_007_566
        end
      end

      context 'when entity is an org' do
        let(:external_dataset) { create(:external_dataset_iapd_advisor) }
        let(:service) { ExternalDatasetService::Iapd.new(entity: org, external_dataset: external_dataset) }

        it 'creates a business' do
          expect { service.match }.to change(Business, :count).by(1)
        end
      end
    end # end describe match

    describe 'unmatch' do
      let(:person) { create(:entity_person) }
      let(:external_dataset) { create(:external_dataset_iapd_owner) }
      let(:service) { ExternalDatasetService::Iapd.new(entity: person, external_dataset: external_dataset) }

      before { service.match }

      it 'removes crd_number' do
        expect { service.unmatch }
          .to change { person.reload.business_person.crd_number }
                .from(7_007_566).to(nil)
      end

      it 'keeps business person' do
        expect { service.unmatch }
          .not_to change { person.reload.business_person.present? }
      end

      it 'removes entity id' do
        expect { service.unmatch }
          .to change { external_dataset.reload.entity_id }.from(person.id).to(nil)
      end
    end

    # private helpers #

    describe 'crd_number' do
      it 'return crd number for iapd advisor' do
        service = ExternalDatasetService::Iapd.new(external_dataset: build(:external_dataset_iapd_advisor))
        expect(service.send(:crd_number)).to eq 126_188
      end

      it 'returns crd number for iapd owner' do
        service = ExternalDatasetService::Iapd.new(external_dataset: build(:external_dataset_iapd_owner))
        expect(service.send(:crd_number)).to eq '7007566'
      end

      it 'returns nil for iapd owner' do
        row_data = { 'owner_key' => '12-12345', 'class' => 'ExternalDataset::IapdOwner' }
        service = ExternalDatasetService::Iapd.new(external_dataset: build(:external_dataset_iapd_owner, row_data: row_data))
        expect(service.send(:crd_number)).to be nil 
      end
    end
  end # end describe iapd
end

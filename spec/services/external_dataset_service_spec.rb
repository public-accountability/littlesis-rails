# frozen_string_literal: true

require 'rails_helper'

describe ExternalDatasetService do

  describe 'Iapd' do
    describe '#validate_match!' do
      let(:external_dataset) { build(:external_dataset, entity_id: nil) }
      # let(:external_dataset_service) { ExternalDatasetService::Iapd.new(external_dataset) }
      let(:crd_number) { Faker::Number.unique.number(5).to_i }
      let(:person) { create(:entity_person) }
      let(:org) { create(:entity_org) }

      it 'raises error if person has crd number' do
        person.add_extension('BusinessPerson', crd_number: crd_number)
        expect { ExternalDatasetService::Iapd.validate_match!(entity: person, external_dataset: external_dataset) }
          .to raise_error(ExternalDatasetService::InvalidMatchError)
      end

      it 'rasies error if org has a crd number' do
        org.add_extension('Business', crd_number: crd_number)
        expect { ExternalDatasetService::Iapd.validate_match!(entity: org, external_dataset: external_dataset) }
          .to raise_error(ExternalDatasetService::InvalidMatchError)
      end

      it 'ok if business does not have a crd number' do
        org.add_extension('Business')
        expect { ExternalDatasetService::Iapd.validate_match!(entity: org, external_dataset: external_dataset) }
          .not_to raise_error
      end

      it 'ok if person does not have a crd number' do
        person
        expect { ExternalDatasetService::Iapd.validate_match!(entity: person, external_dataset: external_dataset) }
          .not_to raise_error
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

    describe '#match' do
      let(:person) { create(:entity_person) }
      let(:org) { create(:entity_org) }
      let(:owner_id) { nil }
      let(:primary_ext) { :person }
      let(:external_dataset) do
        create(:external_dataset, primary_ext: primary_ext, entity_id: nil, row_data: { 'OwnerID' => owner_id })
      end

      context 'with empty owner id' do
        it 'add entity_id to external_dataset' do
          expect { ExternalDatasetService::Iapd.match(entity: person, external_dataset: external_dataset) }
            .to change { external_dataset.reload.entity_id }.from(nil).to(person.id)
        end

        it 'creates business person' do
          expect { ExternalDatasetService::Iapd.match(entity: person, external_dataset: external_dataset) }
            .to change(BusinessPerson, :count).by(1)
        end

        it 'does not create crd_number if empty' do
          ExternalDatasetService::Iapd.match(entity: person, external_dataset: external_dataset)
          expect(person.reload.business_person.crd_number).to be nil
        end
      end

      context 'with owner id' do
        let(:owner_id) { Faker::Number.unique.number(5) }

        it 'creates business person' do
          expect { ExternalDatasetService::Iapd.match(entity: person, external_dataset: external_dataset) }
            .to change(BusinessPerson, :count).by(1)
        end

        it 'add crd number to business person' do
          person.add_extension('BusinessPerson')
          expect(person.business_person.crd_number).to be nil
          ExternalDatasetService::Iapd.match(entity: person, external_dataset: external_dataset)
          expect(person.reload.business_person.crd_number).to eq owner_id.to_i
        end
      end

      context 'when entity is an org' do
        let(:primary_ext) { :org }

        it 'creates a business' do
          expect { ExternalDatasetService::Iapd.match(entity: org, external_dataset: external_dataset) }
            .to change(Business, :count).by(1)
        end
      end
    end
  end
end

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
        expect { ExternalDatasetService::Iapd.validate_match!(entity: person, external_dataset: external_dataset) }
          .not_to raise_error
      end
    end

    describe '#match' do
    end
  end
end

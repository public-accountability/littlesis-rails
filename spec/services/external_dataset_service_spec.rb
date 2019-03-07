# frozen_string_literal: true

require 'rails_helper'

describe ExternalDatasetService do

  describe 'Iapd' do
    describe '#validate_match!' do
      let(:external_dataset) { build(:external_dataset, entity_id: nil) }
      let(:external_dataset_service) { ExternalDatasetService::Iapd.new(external_dataset) }
      let(:crd_number) { Faker::Number.unique.number(5).to_i }
      let(:person) { create(:entity_person) }
      let(:org) { create(:entity_org) }

      it 'raises error if person has crd number' do
        person.add_extension('BusinessPerson', crd_number: crd_number)
        expect { external_dataset_service.validate_match!(person) }
          .to raise_error(ExternalDatasetService::InvalidMatchError)
      end

      it 'rasies error if org has a crd number' do
        org.add_extension('Business', crd_number: crd_number)
        expect { external_dataset_service.validate_match!(org) }
          .to raise_error(ExternalDatasetService::InvalidMatchError)
      end
      
      it 'ok if business does not have a crd number' do
        org.add_extension('Business')
        expect { external_dataset_service.validate_match!(org) }.not_to raise_error
      end

      it 'ok if person does not have a crd number' do
        expect { external_dataset_service.validate_match!(person) }.not_to raise_error
      end
    end
  end
end

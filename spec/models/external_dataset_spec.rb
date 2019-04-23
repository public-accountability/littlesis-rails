require 'rails_helper'

describe ExternalDataset, type: :model do
  it { is_expected.not_to have_db_column(:name) }
  it { is_expected.to have_db_column(:type).of_type(:string) }
  it { is_expected.to have_db_column(:row_data).of_type(:text) }
  it { is_expected.to have_db_column(:entity_id).of_type(:integer) }
  it { is_expected.to have_db_column(:match_data).of_type(:text) }
  it { is_expected.to have_db_column(:primary_ext).of_type(:integer) }
  it { is_expected.to have_db_column(:dataset_key).of_type(:string) }

  it { is_expected.to validate_presence_of(:dataset_key) }
  it { is_expected.to validate_presence_of(:type) }

  it { is_expected.to belong_to(:entity).without_validating_presence }

  it do
    is_expected.to validate_inclusion_of(:type).in_array(ExternalDataset::MODELS)
  end

  specify { expect(ExternalDataset::DATASETS).to eq [:iapd] }
  specify { expect(ExternalDataset::MODELS).to eq ['IapdDatum'] }

  describe 'row_data_class' do
    specify do
      expect(build(:external_dataset_iapd_owner).row_data_class)
        .to eq 'IapdDatum::IapdOwner'
    end

    specify do
      expect(build(:external_dataset_iapd_advisor).row_data_class)
        .to eq 'IapdDatum::IapdAdvisor'
    end

    specify do
      expect(build(:external_dataset).row_data_class).to be nil
    end
  end

  describe 'matched?' do
    it 'is true when model has entity_id' do
      expect(build(:external_dataset, entity_id: rand(1000)).matched?).to be true
    end

    it 'is false when entity_id is null' do
      expect(build(:external_dataset, entity_id: nil).matched?).to be false
    end
  end

  describe 'matches' do
    context 'when external dataset row is for a person' do
      let(:external_dataset) do
        build(:external_dataset, row_data: { 'name' => 'Jane Smith' })
      end

      it 'calls find_matches_for_person' do
        expect(EntityMatcher).to receive(:find_matches_for_person)
                                   .with('Jane Smith', {}).once
        external_dataset.matches
      end
    end

    context 'when external dataset row is for a org' do
      let(:external_dataset) do
        build(:external_dataset, primary_ext: :org, row_data: { 'name' => 'ABC Corp' })
      end

      it 'calls find_matches_for_org' do
        expect(EntityMatcher).to receive(:find_matches_for_org)
                                   .with('ABC Corp', {}).once
        external_dataset.matches
      end
    end
  end

  describe 'match_with' do
    let(:external_dataset) { build(:external_dataset, entity_id: nil) }
    let(:service) { spy('ExternalDatasetService::Iapd') }

    it 'raises error if already matched' do
      expect { build(:external_dataset, entity_id: rand(1000)).match_with(123) }
                 .to raise_error(ExternalDataset::RowAlreadyMatched)
    end

    it 'updates entity id and saves' do
      allow(external_dataset).to receive(:service).and_return(service)
      expect(external_dataset).to receive(:save).once
      expect(external_dataset.match_with(123).entity_id).to eq 123
    end

    it 'calls validate_match! and match on service object' do
      allow(external_dataset).to receive(:save)
      allow(external_dataset).to receive(:service).and_return(service)
      external_dataset.match_with(123).entity_id
      expect(service).to have_received(:validate_match!).once
      expect(service).to have_received(:match).with(entity: 123).once
    end

    it 'returns self' do
      allow(external_dataset).to receive(:service).and_return(service)
      expect(external_dataset).to receive(:save).once
      expect(external_dataset.match_with(123)).to be external_dataset
    end
  end

  describe 'unmatch'

  describe '#entity_name' do
    let(:external_dataset) do
      build(:external_dataset, row_data: { 'name' => 'test' })
    end

    specify do
      expect(external_dataset.send(:entity_name)).to eq 'test'
    end
  end
end

require 'rails_helper'

describe ExternalDataset, type: :model do
  it { is_expected.to have_db_column(:name).of_type(:string) }
  it { is_expected.to have_db_column(:row_data).of_type(:text) }
  it { is_expected.to have_db_column(:entity_id).of_type(:integer) }
  it { is_expected.to have_db_column(:match_data).of_type(:text) }
  it { is_expected.to have_db_column(:primary_ext).of_type(:integer) }

  it do
    is_expected.to validate_inclusion_of(:name).in_array(ExternalDataset::DATASETS)
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
        build(:external_dataset, row_data: { 'Full Legal Name' => 'Jane Smith' })
      end

      it 'calls find_matches_for_person' do
        expect(EntityMatcher).to receive(:find_matches_for_person)
                                   .with('Jane Smith', {}).once
        external_dataset.matches
      end
    end

    context 'when external dataset row is for a org' do
      let(:external_dataset) do
        build(:external_dataset, primary_ext: :org, row_data: { 'Full Legal Name' => 'ABC Corp' })
      end

      it 'calls find_matches_for_org' do
        expect(EntityMatcher).to receive(:find_matches_for_org)
                                   .with('ABC Corp', {}).once
        external_dataset.matches
      end
    end
  end

  describe '#entity_name' do
    let(:external_dataset) do
      build(:external_dataset, row_data: { 'Full Legal Name' => 'test' })
    end

    specify do
      expect(external_dataset.send(:entity_name)).to eq 'test'
    end
  end

end

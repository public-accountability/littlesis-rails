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
    let(:entity) { instance_double('Entity', id: rand(10_000)) }

    before { allow(Entity).to receive(:entity_for).and_return(entity) }

    it 'raises error if already matched' do
      expect { build(:external_dataset, entity_id: rand(1000)).match_with(123) }
                 .to raise_error(ExternalDataset::RowAlreadyMatched)
    end

    it 'calls outs to ExternalDatasetService' do
      expect(ExternalDatasetService).to receive(:validate_match!).once
                                          .with(external_dataset: external_dataset, entity: entity)
      expect(ExternalDatasetService).to receive(:match).once
                                          .with(external_dataset: external_dataset, entity: entity)

      external_dataset.match_with(entity.id)
    end
  end

  describe 'matched and unmatched' do
    before do
      create(:external_dataset, entity_id: rand(1000))
      create(:external_dataset, entity_id: nil)
    end

    specify { expect(ExternalDataset.count).to eq 2 }
    specify { expect(ExternalDataset.unmatched.count).to eq 1 }
    specify { expect(ExternalDataset.matched.count).to eq 1 }
    specify { expect(ExternalDataset.matched.first).not_to eq ExternalDataset.unmatched.first }
  end

  describe '#entity_name' do
    let(:external_dataset) do
      build(:external_dataset, row_data: { 'name' => 'test' })
    end

    specify do
      expect(external_dataset.send(:entity_name)).to eq 'test'
    end
  end
end

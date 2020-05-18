describe ExternalEntity, type: :model do
  it { is_expected.to have_db_column(:dataset).of_type(:integer) }
  it { is_expected.to have_db_column(:match_data).of_type(:text) }
  it { is_expected.to have_db_column(:entity_id).of_type(:integer) }
  it { is_expected.to have_db_column(:external_data_id).of_type(:integer) }
  it { is_expected.to have_db_column(:priority).of_type(:integer) }
  it { is_expected.to have_db_column(:primary_ext).of_type(:string) }
  it { is_expected.to belong_to(:external_data) }
  it { is_expected.to belong_to(:entity).optional }

  specify 'matched?' do
    expect(build(:external_entity, entity_id: nil).matched?).to be false
    expect(build(:external_entity, entity_id: 123).matched?).to be true
  end

  describe 'match_with' do
    before do
      create(:tag, name: 'iapd')
    end

    context 'with a iapd advisor' do
      let(:external_entity) { create(:external_entity_iapd_advisor) }
      let(:entity) { create(:entity_org) }

      it 'updates entity id field' do
        expect { external_entity.match_with(entity) }
          .to change(external_entity, :entity_id)
                .from(nil).to(entity.id)
      end

      it 'creates an external link' do
        expect(entity.external_links.crd).to be_empty
        external_entity.match_with(entity)
        expect(entity.reload.external_links.crd.length).to eq 1
        expect(entity.reload.external_links.crd.first.link_id).to eq external_entity.external_data.dataset_id
      end
    end
  end

  describe 'matched/unmatched' do
    let(:entity) { create(:entity_org) }

    before do
      ExternalEntity.create!(
        dataset: 'iapd_advisors',
        external_data: create(:external_data_iapd_advisor),
        entity: entity
      )

      ExternalEntity.create!(
        dataset: 'iapd_advisors',
        external_data: ExternalData.create!(
          attributes_for(:external_data_iapd_advisor).merge(dataset_id: Faker::Number.number.to_s)
        )
      )
    end

    specify do
      expect(ExternalEntity.count).to eq 2
      expect(ExternalEntity.unmatched.count).to eq 1
      expect(ExternalEntity.matched.count).to eq 1
      expect(ExternalEntity.matched.first).not_to eq ExternalEntity.unmatched.first
    end
  end
end

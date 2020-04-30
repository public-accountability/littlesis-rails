describe ExternalEntity, type: :model do
  it { is_expected.to have_db_column(:dataset).of_type(:integer) }
  it { is_expected.to have_db_column(:match_data).of_type(:text) }
  it { is_expected.to have_db_column(:entity_id).of_type(:integer) }
  it { is_expected.to have_db_column(:external_data_id).of_type(:integer) }
  it { is_expected.to belong_to(:external_data) }
  it { is_expected.to belong_to(:entity).optional }

  specify 'matched?' do
    expect(build(:external_entity, entity_id: nil).matched?).to be false
    expect(build(:external_entity, entity_id: 123).matched?).to be true
  end

  describe 'match_with' do
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
end

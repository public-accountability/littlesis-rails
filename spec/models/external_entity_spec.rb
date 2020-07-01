describe ExternalEntity, type: :model do
  subject { build(:external_entity) }

  it { is_expected.to have_db_column(:dataset).of_type(:integer) }
  it { is_expected.to have_db_column(:match_data).of_type(:text) }
  it { is_expected.to have_db_column(:entity_id).of_type(:integer) }
  it { is_expected.to have_db_column(:external_data_id).of_type(:integer) }
  it { is_expected.to have_db_column(:priority).of_type(:integer) }
  it { is_expected.to have_db_column(:primary_ext).of_type(:string) }
  it { is_expected.to belong_to(:external_data) }
  it { is_expected.to belong_to(:entity).optional }

  specify 'matched?' do
    expect(build(:external_entity_nycc, entity_id: nil).matched?).to be false
    expect(build(:external_entity_nycc, entity_id: 123).matched?).to be true
  end

  describe 'match_with' do
    context 'with an iapd advisor' do
      let(:aum) { 2_397_975_077 } # see factories/external_data
      let(:external_entity) { create(:external_entity_iapd_advisor) }
      let(:entity) { create(:entity_org) }

      before { create(:tag, name: 'iapd') }

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

      it 'creates an new business and sets aum' do
        expect { external_entity.match_with(entity) }.to change(Business, :count).by(1)
        expect(entity.business.aum).to eq aum
      end

      it 'sets aum on existing business' do
        entity.add_extension('Business')
        expect { external_entity.match_with(entity) }.not_to change(Business, :count)
        expect(entity.reload.business.aum).to eq aum
      end
    end

    context 'with a nys_filer' do
      let(:politician) { create(:entity_person) }
      let(:external_entity) { create(:external_entity_nys_filer) }

      it 'updates entity id and creates an external link' do
        expect { external_entity.match_with(politician) }
          .to change(external_entity, :entity_id)
                .from(nil).to(politician.id)

        expect(external_entity.entity.external_links.nys_filer.first.link_id).to eq 'A123456'
      end
    end
  end

  describe 'match_with_new_entity' do
    before { create(:tag, name: 'iapd') }

    let(:external_entity) { create(:external_entity_iapd_advisor) }

    let(:entity_params) do
      {
        name: 'Boenning & Scattergood',
        blurb: 'Investor Advisor',
        primary_ext: 'Org',
        last_user_id: 1
      }
    end

    context 'with an iapd advisor' do
      it 'creates a new entity' do
        expect { external_entity.match_with_new_entity(entity_params) }
          .to change(Entity, :count).by(1)
      end

      it 'updates entity_id field' do
        external_entity.match_with_new_entity(entity_params)
        expect(external_entity.reload.entity_id).to eq Entity.last.id
      end
    end
  end

  describe 'unmatch!' do
    context 'with a nys_filer' do
      let(:politician) { create(:entity_person) }
      let(:external_entity) { create(:external_entity_nys_filer) }

      before do
        external_entity.match_with(politician)
      end

      it 'removes entity and external link' do
        expect(politician.external_links.nys_filer.exists?).to be true
        external_entity.unmatch!
        expect(politician.reload.external_links.nys_filer.exists?).to be false
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

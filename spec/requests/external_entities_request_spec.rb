describe "ExternalEntities", type: :request do
  let(:user) { create_basic_user }

  before do
    login_as(user, :scope => :user)
    create(:tag, name: 'iapd')
  end

  after { logout(:user) }

  describe 'update' do
    let(:entity) { create(:entity_org) }

    let(:external_entity) do
      create :external_entity, dataset: 'iapd_advisors', external_data: build(:external_data_iapd_advisor)
    end

    it 'matches entity' do
      expect do
        patch external_entity_path(external_entity), params: { entity_id: entity.id }
      end.to change { external_entity.reload.entity_id }
               .from(nil).to(entity.id)
    end

    it 'creates a new External Link' do
      expect do
        patch external_entity_path(external_entity), params: { entity_id: entity.id }
      end.to change(ExternalLink, :count).by(1)
    end

    it 'redirects to external_entity route' do
      patch external_entity_path(external_entity), params: { entity_id: entity.id }
      expect(response).to have_http_status 302
      expect(response.location).to include external_entity_path(external_entity)
    end
  end

  describe 'create new entity' do
    let(:external_entity) do
      create :external_entity, dataset: 'iapd_advisors', external_data: build(:external_data_iapd_advisor)
    end

    let(:params) do
      { entity: { name: 'Foo Bar Inc', blurb: 'Foo Investor Advisor' } }
    end

    it 'creates a new entity with correct params' do
      expect do
        patch external_entity_path(external_entity), params: params
      end.to change(Entity, :count).by(1)

      expect(Entity.last.attributes.slice('name', 'blurb'))
        .to eq('name' => 'Foo Bar Inc', 'blurb' => 'Foo Investor Advisor')
    end

    it 'redirects to external_entity route' do
      patch external_entity_path(external_entity), params: params
      expect(response).to have_http_status 302
      expect(response.location).to include external_entity_path(external_entity)
    end
  end
end

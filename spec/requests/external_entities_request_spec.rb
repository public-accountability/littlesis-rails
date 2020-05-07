describe "ExternalEntities", type: :request do
  let(:user) { create_basic_user }

  before { login_as(user, :scope => :user) }

  after  { logout(:user) }

  describe 'update' do
    let(:entity) { create(:entity_org) }

    let(:external_entity) do
      create :external_entity, dataset: 'iapd_advisors', external_data: build(:external_data_iapd_advisor)
    end

    before do
      create(:tag, name: 'iapd')
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
      expect(response).to redirect_to external_entity_path(external_entity)
    end
  end
end

describe ExternalEntitiesController, type: :controller do
  it { is_expected.to route(:get, '/external_entities/123').to(action: :show, id: 123) }
  it { is_expected.to route(:patch, '/external_entities/123').to(action: :update, id: 123) }

  describe 'show' do
    it 'renders already_matched page when entity if entity is matched' do
      external_entity = build(:external_entity, id: rand(1000), entity_id: rand(1000))
      expect(ExternalEntity).to receive(:find).once.and_return(external_entity)
      allow(controller).to receive(:authenticate_user!)
      get :show, params: { id: external_entity.id }
      expect(response).to render_template 'already_matched'
    end
  end
end

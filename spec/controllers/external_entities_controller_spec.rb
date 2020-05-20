describe ExternalEntitiesController, type: :controller do
  it { is_expected.to route(:get, '/external_entities/123').to(action: :show, id: 123) }
  it { is_expected.to route(:get, '/external_entities/nycc/123').to(action: :show, id: 123, dataset: 'nycc') }
  it { is_expected.not_to route(:get, '/external_entities/nycc/invalid_id').to(action: :show, id: 'invalid_id', dataset: 'nycc') }

  it { is_expected.to route(:get, '/external_entities/random').to(action: :random) }
  it { is_expected.to route(:get, '/external_entities/nycc/random').to(action: :random, dataset: 'nycc') }
  it { is_expected.to route(:patch, '/external_entities/123').to(action: :update, id: 123) }
  it { is_expected.to route(:get, '/external_entities/nycc').to(action: :dataset, dataset: 'nycc') }
  it { is_expected.not_to route(:get, '/external_entities/invalid').to(action: :dataset, dataset: 'invalid') }

  describe 'show' do
    it 'renders already_matched page when entity if entity is matched' do
      external_entity = build(:external_entity, id: rand(1000), entity_id: rand(1000))
      expect(ExternalEntity).to receive(:find).once.and_return(external_entity)
      allow(controller).to receive(:authenticate_user!)
      get :show, params: { id: external_entity.id }
      expect(response).to render_template 'already_matched'
    end
  end

  describe 'random' do
    it 'redirects to random id' do
      allow(controller).to receive(:authenticate_user!)
      expect(ExternalEntity).to receive(:unmatched).once
                                  .and_return(double(order: double(limit: double(pluck: [123]))))

      get :random
      expect(response.status).to eq 302
      expect(response.location).to include "external_entities/123"
    end

  end
end

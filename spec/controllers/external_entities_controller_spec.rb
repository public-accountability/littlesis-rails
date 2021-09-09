describe ExternalEntitiesController, type: :controller do
  it { is_expected.not_to route(:get, '/external_entities').to(action: :index) }
  it { is_expected.to route(:get, '/external_entities/123').to(action: :show, id: 123) }
  it { is_expected.to route(:get, '/external_entities/nycc/123').to(action: :show, id: 123, dataset: 'nycc') }
  it { is_expected.not_to route(:get, '/external_entities/nycc/invalid_id').to(action: :show, id: 'invalid_id', dataset: 'nycc') }
  it { is_expected.to route(:get, '/external_entities/random').to(action: :random) }
  it { is_expected.to route(:get, '/external_entities/nycc/random').to(action: :random, dataset: 'nycc') }
  it { is_expected.to route(:patch, '/external_entities/123').to(action: :update, id: 123) }
  it { is_expected.not_to route(:get, '/external_entities/nycc').to(action: :dataset, dataset: 'nycc') }
end

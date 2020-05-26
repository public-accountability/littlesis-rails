describe ExternalDataController, type: :controller do
  it { is_expected.to route(:get, '/external_data/nycc').to(action: :dataset, dataset: 'nycc') }
  it { is_expected.not_to route(:get, '/external_data/invalid').to(action: :dataset, dataset: 'invalid') }
end

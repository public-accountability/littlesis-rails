describe ExternalRelationshipsController, type: :controller do
  it { is_expected.to route(:get, '/external_relationships/123').to(action: :show, id: 123) }
  it { is_expected.to route(:get, '/external_relationships/random').to(action: :random) }
  it { is_expected.to route(:patch, '/external_relationships/123').to(action: :update, id: 123) }
end

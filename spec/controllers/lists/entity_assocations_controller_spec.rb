describe Lists::EntityAssociationsController, type: :controller do
  it { is_expected.to route(:get, '/lists/1/entities/bulk/new').to(action: :new, list_id: 1) }
  it { is_expected.to route(:post, '/lists/1/entities/bulk').to(action: :create, list_id: 1) }
end

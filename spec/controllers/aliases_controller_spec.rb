describe AliasesController, type: :controller do
  let(:entity) { create(:entity_org) }

  it { is_expected.to use_before_action(:authenticate_user!) }
  it { is_expected.to route(:patch, '/aliases/123').to(action: :update, id: 123) }
  it { is_expected.to route(:post, '/aliases').to(action: :create) }
  it { is_expected.to route(:delete, '/aliases/123').to(action: :destroy, id: 123) }
  it { is_expected.to route(:patch, '/aliases/123/make_primary').to(action: :make_primary, id: 123) }
end

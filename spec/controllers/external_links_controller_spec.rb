describe ExternalLinksController, type: :controller do
  it { is_expected.to route(:post, '/external_links').to(action: :create) }
  it { is_expected.to route(:patch, '/external_links/1').to(action: :update, id: 1) }
end

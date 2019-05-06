describe PartnersController, type: :controller do
  it { is_expected.to route(:get, '/partners/corporate-mapping-project').to(action: :cmp) }
end

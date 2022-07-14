describe NewslettersController, type: :controller do
  it { is_expected.to route(:get, '/newsletters/signup').to(action: :signup) }
  it { is_expected.to route(:post, '/newsletters/signup').to(action: :signup_action) }
  it { is_expected.to route(:get, "/newsletters/confirmation/e97750883e1819ac17a01c079d439dea").to(action: :confirmation, secret: "e97750883e1819ac17a01c079d439dea") }
  it { is_expected.not_to route(:get, '/newsletters/confirmation/foobar').to(action: :confirmation, secret: 'foobar') }
end

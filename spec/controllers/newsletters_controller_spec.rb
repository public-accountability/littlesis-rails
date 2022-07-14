describe NewslettersController, type: :controller do
  it { is_expected.to route(:get, '/newsletters/signup').to(action: :signup) }
  it { is_expected.to route(:post, '/newsletters/signup').to(action: :signup_action) }
end

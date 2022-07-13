describe NewslettersController, type: :controller do
  it { is_expected.to route(:get, '/newsletters/status').to(action: :status) }
  it { is_expected.to route(:post, '/newsletters/email_status').to(action: :email_status) }
end

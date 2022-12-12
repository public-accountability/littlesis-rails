describe AdminController, type: :controller do
  it { is_expected.to route(:get, '/admin').to(action: :home) }
  it { is_expected.to route(:get, '/admin/tags').to(action: :tags) }
  it { is_expected.to route(:get, '/admin/stats').to(action: :stats) }
  it { is_expected.to route(:post, '/admin/test_email').to(action: :test_email) }
  it { is_expected.to route(:post, '/admin/users/123/set_role').to(action: :set_role, userid: "123") }
  it { is_expected.to route(:post, '/admin/users/123/resend_confirmation_email').to(action: :resend_confirmation_email, userid: "123") }
  it { is_expected.to route(:post, '/admin/users/123/reset_password').to(action: :reset_password, userid: "123") }
  it { is_expected.to route(:post, '/admin/users/123/delete_user').to(action: :delete_user, userid: "123") }
end

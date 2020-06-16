describe 'External Relationships matcher' do
  before { login_as(create_basic_user, scope: :user) }
  after { logout(:user) }

  it 'shows relationships details'
  it 'has matching tools for both entities'
end

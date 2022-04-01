describe ActionNetwork do
  specify 'email_from_user' do
    user = User.new(email: 'user@example.com')
    expect(ActionNetwork.email_from_user(user)).to eq 'user@example.com'
    expect(ActionNetwork.email_from_user('user@example.com')).to eq 'user@example.com'
  end
end

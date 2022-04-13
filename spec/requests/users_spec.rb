describe 'Users' do
  describe '/users/check_username' do
    subject { json }

    let(:username) { '' }

    before do
      post '/users/check_username', params: { 'username' => username }
    end

    context 'with valid username' do
      let(:username) { FactoryBot.attributes_for(:user)[:username] }

      it do
        is_expected.to eq('username' => username, 'valid' => true)
      end
    end

    context 'with invalid username' do
      let(:username) { '12356' }

      it do
        is_expected.to eq('username' => username, 'valid' => false)
      end
    end
  end

  describe 'updating settings' do
    let(:admin_user) { create_admin_user }

    before do
      login_as(admin_user, :scope => :user)
    end

    after { logout(:user) }

    it 'admins can update can show stars settings' do
      expect(admin_user.settings.show_stars).to be false
      put "/users/settings", params: { settings: { show_stars: true } }, as: :json
      expect(admin_user.reload.settings.show_stars).to be true
      expect(response.status).to eq 302
      expect(response.location).to include '/settings'
    end
  end
end

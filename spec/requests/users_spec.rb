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

  describe 'attempting to add an ability that does not exist' do
    let(:user) { create_basic_user }
    let(:admin) { create_admin_user }

    before do
      user
      login_as(admin, :scope => :user)
      post "/users/#{user.id}/add_permission", params: { permission: 'dance' }
    end

    after { logout(:user) }

    it 'returns a bad request' do
      expect(response).to have_http_status :bad_request
      expect(response.body).to be_blank
    end
  end

  describe 'updating settings' do
    let(:user) { create_basic_user }

    before do
      login_as(user, :scope => :user)
    end

    after { logout(:user) }

    it 'changes oligrapher_beta' do
      expect(user.settings.oligrapher_beta).to be false
      put "/users/settings", params: { settings: { oligrapher_beta: true } }, as: :json
      expect(user.reload.settings.oligrapher_beta).to be true
      expect(response.status).to eq 302
      expect(response.location).to include '/users/edit'
    end
  end
end

describe UsersController, type: :controller do
  describe 'routes' do
    it { is_expected.not_to route(:get, '/users').to(action: :index) }
    it { is_expected.to route(:get, '/users/a_username').to(action: :show, username: 'a_username') }
    it { is_expected.to route(:get, '/users/a_username/edits').to(action: :edits, username: 'a_username') }
    it { is_expected.to route(:post, '/users/check_username').to(action: :check_username) }
  end

  describe 'GET #edits' do
    let(:user) { create_editor }

    describe 'as an admin' do
      login_admin
      before { get :edits, params: { username: user.username } }

      it { is_expected.to render_template('edits') }
    end

    describe 'as a regular user' do
      login_user
      before { get :edits, params: { username: user.username } }

      it { is_expected.to respond_with(403) }
    end

    describe 'when user is accessing their own page' do
      before do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in user, scope: :user
        get :edits, params: { username: user.username }
      end

      it { is_expected.to render_template('edits') }
    end
  end

  describe '#success' do
    before { get :success }

    it { is_expected.to respond_with(200) }
    it { is_expected.to render_template('success') }
  end
end

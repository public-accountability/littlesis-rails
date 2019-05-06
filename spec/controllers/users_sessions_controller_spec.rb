describe Users::SessionsController, type: :controller do
  describe 'Routes' do
    it { is_expected.to route(:get, '/login').to(action: :new) }
    it { is_expected.to route(:post, '/login').to(action: :create) }
    it { is_expected.to route(:get, '/logout').to(action: :destroy) }
  end

  describe 'X-Frame-Options' do
    before { request.env['devise.mapping'] = Devise.mappings[:user] }

    it 'sets for login' do
      get :new
      expect(response.headers['X-Frame-Options']).to eq 'SAMEORIGIN'
    end
  end
end

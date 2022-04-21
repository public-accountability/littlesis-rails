describe HomeController, type: :controller do
  describe 'routes' do
    it { is_expected.to route(:get, '/flag').to(action: :flag) }
    it { is_expected.to route(:post, '/flag').to(action: :flag) }
    it { is_expected.to route(:post, '/home/newsletter_signup').to(action: :newsletter_signup) }
    it { is_expected.to route(:post, '/home/pai_signup').to(action: :pai_signup) }
    it { is_expected.to route(:post, '/home/pai_signup/press').to(action: :pai_signup, tag: 'press') }
  end

  describe 'GET home/dashboard' do
    login_user
    before { get :dashboard }

    it { is_expected.to respond_with(:success) }
  end

  describe '/flag' do
    describe 'GET' do
      before { get :flag }

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template('flag') }
    end
  end
end

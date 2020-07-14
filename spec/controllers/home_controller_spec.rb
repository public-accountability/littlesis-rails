describe HomeController, type: :controller do
  describe 'routes' do
    it { is_expected.to route(:get, '/contact').to(action: :contact) }
    it { is_expected.to route(:post, '/contact').to(action: :contact) }
    it { is_expected.to route(:get, '/flag').to(action: :flag) }
    it { is_expected.to route(:post, '/flag').to(action: :flag) }
    it { is_expected.to route(:post, '/home/newsletter_signup').to(action: :newsletter_signup) }
    it { is_expected.to route(:post, '/home/pai_signup').to(action: :pai_signup) }
    it { is_expected.to route(:post, '/home/pai_signup/press').to(action: :pai_signup, tag: 'press') }
  end

  describe 'GET contact' do
    before { get :contact }

    it { is_expected.to respond_with(:success) }
    it { is_expected.to render_template('contact') }
    it { is_expected.not_to set_flash.now }
  end

  describe 'GET home/dashboard' do
    login_user
    before { get :dashboard }

    it { is_expected.to respond_with(:success) }
  end

  describe 'POST contact' do
    describe 'no name provided' do
      let(:params) { { email: 'email@email.com', message: 'hey' } }

      before { post :contact, params: params }

      it { is_expected.to set_flash.now[:alert] }
      it { is_expected.to render_template('contact') }
    end

    describe 'no email provided' do
      let(:params) { { name: 'me', message: 'hey' } }

      before { post :contact, params: params }

      it { is_expected.to set_flash.now[:alert] }
      it { is_expected.to render_template('contact') }
    end

    describe 'no message provided' do
      let(:params) { { name: 'me', email: 'email@email.com', message: '' } }

      before { post :contact, params: params }

      it { is_expected.to set_flash.now[:alert] }
      it { is_expected.to render_template('contact') }

      it ' assigns given name to @name' do
        expect(assigns(:name)).to eql 'me'
      end
    end

    describe 'fields filled out' do
      let(:post_params) { { name: 'me', email: 'email@email.com', message: 'hey' } }

      before do
        email = double('contact_email')
        expect(controller).to receive(:verify_math_captcha)
                                .once.and_return(true)
        expect(email).to receive(:deliver_later)
        expect(NotificationMailer)
          .to receive(:contact_email).with(hash_including(post_params)).and_return(email)
        post :contact, params: post_params
      end

      it { is_expected.to_not set_flash.now[:alert] }
      it { is_expected.to set_flash.now[:notice] }
      it { is_expected.to render_template('contact') }
    end
  end

  describe '/flag' do
    describe 'GET' do
      before { get :flag }

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template('flag') }
    end

    describe 'POST' do
      context 'when no email provided' do

        before do
          expect(NotificationMailer).not_to receive(:flag_email)
          post :flag, params: { url: 'http://url', message: 'hey' }
        end

        it { is_expected.to set_flash.now[:alert] }
        it { is_expected.to render_template('flag') }
      end

      context 'when no message provided' do
        before do
          expect(NotificationMailer).not_to receive(:flag_email)
          post :flag, params: { url: 'http://url', email: 'test@example.com' }
        end
        it { is_expected.to set_flash.now[:alert] }
        it { is_expected.to render_template('flag') }
      end

      context 'when all required params provided' do
        let(:params) { { 'url' => 'http://url', 'email' => 'test@example.com', 'message' => 'hey' } }

        before do
          expect(NotificationMailer)
            .to receive(:flag_email).with(params).and_return(double(deliver_later: nil))
          post :flag, params: { url: 'http://url', email: 'test@example.com', message: 'hey' }
        end

        it { is_expected.not_to set_flash.now[:alert] }
        it { is_expected.to set_flash.now[:notice] }
        it { is_expected.to render_template('flag') }
      end
    end
  end

  describe 'pai_signup_ip_limit' do
    let(:ip) { Faker::Internet.ip_v6_address }

    it 'denies access after 4 requests' do
      4.times { controller.send(:pai_signup_ip_limit, ip) }
      expect(Rails.cache.read("pai_signup_request_count_for_#{ip}")).to eq 4
      expect(Rails.logger).to receive(:warn).with("#{ip} has submitted too many requests this hour!").once
      expect { controller.send(:pai_signup_ip_limit, ip) }.to raise_error(Exceptions::PermissionError)
    end
  end
end

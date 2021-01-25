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

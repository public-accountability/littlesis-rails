require 'email_spec'
require 'email_spec/rspec'

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

  describe 'pai_signup_ip_limit' do
    let(:ip) { Faker::Internet.ip_v6_address }
    let(:logger) { instance_double(ActiveSupport::Logger) }

    before do
      allow(Rails).to receive(:logger).and_return(logger)
      allow(logger).to receive(:warn)
    end

    it 'denies access after 4 requests' do
      4.times { controller.send(:pai_signup_ip_limit, ip) }
      expect(Rails.cache.read("pai_signup_request_count_for_#{ip}")).to eq 4
      expect { controller.send(:pai_signup_ip_limit, ip) }.to raise_error(Exceptions::PermissionError)
      expect(logger).to have_received(:warn).with("#{ip} has submitted too many requests this hour!").once
    end
  end
end

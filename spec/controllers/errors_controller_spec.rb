RSpec.describe ErrorsController, type: :controller do
  it { is_expected.to route(:get, '/bug_report').to(action: :bug_report) }
  it { is_expected.to route(:post, '/bug_report').to(action: :file_bug_report) }

  describe "GET #bug_report" do
    before { get :bug_report }

    it { is_expected.to respond_with(:success) }
    it { is_expected.to render_template('bug_report') }
  end

  describe 'POST #file_bug_report' do
    let(:params) do
      {
        :type => 'Bug Report',
        :summary => "Our government is run by deranged capitalists!",
        :page => "https://LittleSis.org"
      }
    end

    before do
      expect(NotificationMailer).to receive(:bug_report_email)
                                      .with(params)
                                      .and_return(double(:deliver_later => nil))
    end

    context 'with a signed-in user' do
      before do
        expect(controller).to receive(:user_signed_in?).once.and_return(true)
        post :file_bug_report, params: params
      end

      it { is_expected.to set_flash[:notice] }
      it { is_expected.to redirect_to('/home/dashboard') }
    end

    context 'with an anonymous user' do
      before do
        expect(controller).to receive(:user_signed_in?).once.and_return(false)
        post :file_bug_report, params: params
      end

      it { is_expected.to set_flash.now[:notice] }
      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template('bug_report') }
    end
  end
end

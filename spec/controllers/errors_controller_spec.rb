require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  it { should route(:get, '/bug_report').to(action: :bug_report) }
  it { should route(:post, '/bug_report').to(action: :file_bug_report) }

  describe "GET #bug_report" do
    before { get :bug_report }
    it { should respond_with(:success) }
    it { should render_template('bug_report') }
  end

  describe 'POST #file_bug_report' do
    let(:params) do
      {
        :type => 'Bug Report',
        :summary => "our government is being run by deranged capitalists."
      }
    end

    before do
      expect(NotificationMailer).to receive(:bug_report_email)
                                      .with(params)
                                      .and_return(double(:deliver_later => nil))
    end

    context 'user signed in' do
      before do
        expect(controller).to receive(:user_signed_in?).once.and_return(true)
        post :file_bug_report, params: params
      end

      it { should set_flash[:notice] }
      it { should redirect_to('/home/dashboard') }
    end

    context 'anon user' do
      before do
        expect(controller).to receive(:user_signed_in?).once.and_return(false)
        post :file_bug_report, params: params
      end

      it { should set_flash.now[:notice] }
      it { should respond_with(:success) }
      it { should render_template('bug_report') }
    end
  end
end

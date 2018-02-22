require 'rails_helper'

describe Users::ConfirmationsController, type: :controller do
  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
    @user = build(:user)
    expect(User).to receive(:confirm_by_token).and_return(@user)
    expect(UserMailer).to receive(:welcome_email)
                            .with(@user).and_return(double(:deliver_later => nil))
    expect(@user).to receive(:create_default_permissions).once
  end

  context 'request is not from a restricted ip' do
    before do
      expect(@user).not_to receive(:update)
      expect(NotificationMailer).to receive(:signup_email)
                                      .with(@user).and_return(double(:deliver_later => nil))
      expect(NewsletterSignupJob).to receive(:perform_later).with(@user)
      expect(@user).to receive(:delay).once.and_return(double(:create_chat_account => nil))
      get :show
    end
    it { should respond_with(302) }
  end

  context 'request is from a restricted ip' do
    before do
      expect(IpBlocker).to receive(:restricted?).with('0.0.0.0').and_return(true)
      expect(NotificationMailer).not_to receive(:signup_email)
      expect(NewsletterSignupJob).not_to receive(:perform_later)
      expect(@user).to receive(:update).with(is_restricted: true)
      expect(@user).not_to receive(:delay)
      get :show
    end
    it { should respond_with(302) }
  end
end

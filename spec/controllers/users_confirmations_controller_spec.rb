describe Users::ConfirmationsController, type: :controller do
  let(:user) { build(:user, newsletter: true) }

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
    allow(User).to receive(:confirm_by_token).and_return(user)
  end

  describe 'Confirming email address' do
    specify do
      # expect(user).to receive(:create_default_permissions).once
      expect(user).not_to receive(:update)
      expect(UserMailer).to receive(:welcome_email).with(user).and_return(double(:deliver_later => nil))
      # expect(NotificationMailer).to receive(:signup_email).with(@user).and_return(double(:deliver_later => nil))
      expect(NewsletterSignupJob).to receive(:perform_later).with(user.email)
      get :show
      expect(response).to have_http_status :found
    end
  end

  # context 'request is from a restricted ip' do
  #   before do
  #     expect(IpBlocker).to receive(:restricted?).with('0.0.0.0').and_return(true)
  #     expect(NotificationMailer).not_to receive(:signup_email)
  #     expect(NewsletterSignupJob).not_to receive(:perform_later)
  #     expect(@user).to receive(:update).with(is_restricted: true)
  #     expect(@user).not_to receive(:delay)
  #     get :show
  #   end
  #   it { should respond_with(302) }
  # end
end

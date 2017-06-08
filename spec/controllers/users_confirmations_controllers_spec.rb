require 'rails_helper'

describe Users::ConfirmationsController, type: :controller do
  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
    user = build(:user)
    expect(User).to receive(:confirm_by_token).and_return(user)
    expect(UserMailer).to receive(:welcome_email)
                            .with(user).and_return(double(:deliver_later => nil))
    expect(NotificationMailer).to receive(:signup_email)
                            .with(user).and_return(double(:deliver_later => nil))

    expect(user).to receive(:delay).once.and_return(double(:create_chat_account => nil))

    get :show
  end

  it { should respond_with(302) }
end

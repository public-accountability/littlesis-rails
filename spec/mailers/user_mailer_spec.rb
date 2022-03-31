# frozen_string_literal: true

describe UserMailer, type: :mailer do
  describe 'welcome email' do
    let(:user) { create_basic_user_with_profile }
    let(:mail) { UserMailer.welcome_email(user) }

    it 'addresses email to the user' do
      expect(mail.to).to eq [user.email]
    end

    it 'greets the user politely' do
      expect(mail.encoded).to include "Dear #{user.user_profile.name},"
    end

    it 'contains link to login' do
      expect(mail.encoded).to include 'https://littlesis.org/login'
    end
  end
end

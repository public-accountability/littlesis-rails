# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.welcome_email User.random
  end
end

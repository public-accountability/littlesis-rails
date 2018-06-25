# frozen_string_literal: true

class NewsletterSignupJob < ApplicationJob
  queue_as :default

  def perform(email_address_or_user, signup_type = nil)
    TypeCheck.check email_address_or_user, [User, String]

    if email_address_or_user.is_a?(User)
      ActionNetwork.signup email_address_or_user
    elsif signup_type == 'newsletter'
      ActionNetwork.add_email_to_newsletter email_address_or_user
    elsif signup_type == 'pai'
      ActionNetwork.add_email_to_pai email_address_or_user
    else
      raise ArgumentError
    end
  end
end

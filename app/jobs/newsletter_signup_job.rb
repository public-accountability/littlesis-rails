# frozen_string_literal: true

class NewsletterSignupJob < ApplicationJob
  queue_as :default

  ACTIONS = %w[newsletter pai press].to_set.freeze

  def perform(email_address_or_user, signup_type = nil)
    TypeCheck.check email_address_or_user, [User, String]

    if email_address_or_user.is_a?(User)
      ActionNetwork.signup email_address_or_user
    elsif ACTIONS.include? signup_type
      ActionNetwork.public_send "add_email_to_#{signup_type}", email_address_or_user
    else
      raise ArgumentError
    end
  end
end

class NewsletterSignupJob < ApplicationJob
  queue_as :default

  def perform(email_address_or_user)
    if email_address_or_user.is_a?(String)
      ActionNetwork.add_email_to_newsletter email_address_or_user
    elsif email_address_or_user.is_a?(User)
      ActionNetwork.signup email_address_or_user
    else
      raise ArgumentError, "NewsletterSignupJob accepts Email Addresses or Users"
    end
  end
end

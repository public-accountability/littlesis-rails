class NewsletterSignupJob < ApplicationJob
  queue_as :default

  def perform(email_address)
    ActionNetwork.add_email_to_newsletter(email_address)
  end
end

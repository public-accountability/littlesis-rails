# frozen_string_literal: true

module NewsletterSignupConfirmationService
  def self.run(email, tags)
    confirmation_link = NewslettersConfirmationLink.create(email, tags)
    NewsletterMailer.confirmation_email(confirmation_link).deliver_later
  end
end

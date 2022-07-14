# frozen_string_literal: true

class NewsletterMailerPreview < ActionMailer::Preview
  def confirmation_email
    confirmation_link = NewslettersConfirmationLink.create(Faker::Internet.email, ['tech'])
    NewsletterMailer.confirmation_email(confirmation_link)
  end
end

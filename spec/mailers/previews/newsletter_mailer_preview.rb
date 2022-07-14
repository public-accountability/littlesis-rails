# frozen_string_literal: true

class NewsletterMailerPreview < ActionMailer::Preview
  def confirmation_email
    confirmation_link = NewslettersConfirmationLink.create(Faker::Internet.email, ['tech'])
    NewsletterMailer.with(email: confirmation_link.email, url: confirmation_link.url).confirmation_email
  end
end

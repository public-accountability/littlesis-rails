# frozen_string_literal: true

class NewsletterMailer < ApplicationMailer
  # @param confirmation_link [NewslettersConfirmationLink]
  def confirmation_email(confirmation_link)
    @confirmation_link = confirmation_link
    mail(to: @confirmation_link.email, subject: "LittleSis Newsletter Confirmation")
  end
end

# frozen_string_literal: true

class NewsletterMailer < ApplicationMailer
  def confirmation_email
    @url = params[:url]
    mail(to: params[:email], subject: "LittleSis Newsletter Confirmation")
  end
end

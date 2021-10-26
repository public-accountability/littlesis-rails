# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.config.littlesis[:default_from_email]
  layout 'mailer'
end

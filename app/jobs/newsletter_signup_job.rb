# frozen_string_literal: true

class NewsletterSignupJob < ApplicationJob
  queue_as :default

  def perform(email)
    user = Powerbase::User.new(email)
    user.create unless user.present?
    user.add_to(:signup)
  end
end

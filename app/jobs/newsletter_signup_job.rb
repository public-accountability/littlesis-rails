# frozen_string_literal: true

class NewsletterSignupJob < ApplicationJob
  queue_as :default

  def perform(email)
    user = Powerbase::User.new(email)
    user.create
    user.add_to(:signup)
  end
end

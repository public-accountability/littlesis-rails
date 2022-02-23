# frozen_string_literal: true

class NewsletterSignupJob < ApplicationJob
  queue_as :default

  def perform(user_or_email, lists = [:newsletter])
    ActionNetwork.signup(user_or_email, lists)
  end
end

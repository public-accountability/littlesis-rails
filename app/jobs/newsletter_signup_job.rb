# frozen_string_literal: true

class NewsletterSignupJob < ApplicationJob
  queue_as :default

  # Groups: signup, newsletter, tech
  def perform(email, groups = [])
    user = Powerbase::User.new(email)
    user.create
    groups.each do |group|
      user.add_to(group)
    end
  end
end

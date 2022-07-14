# frozen_string_literal: true

class NewslettersController < ApplicationController
  def signup
  end

  def signup_action
    RateLimiter.rate_limit "newsletter_sigup_count/#{request.remote_ip}"
    permitted = params.require(:newsletters).permit(:email, tags: [])
    NewsletterSignupConfirmationService.run(permitted.fetch(:email), permitted.fetch(:tags))
    redirect_to :signup, params: { c: true }
  end
end

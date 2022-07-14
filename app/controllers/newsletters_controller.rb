# frozen_string_literal: true

class NewslettersController < ApplicationController
  def signup
  end

  def signup_action
    RateLimiter.rate_limit "newsletter_sigup_count/#{request.remote_ip}"
    permitted = params.require(:newsletters).permit(:email, tags: [])
    confirmation_link = NewslettersConfirmationLink.create(permitted.fetch(:email), permitted.fetch(:tags))
    NewsletterMailer.confirmation_email(confirmation_link).deliver_later
    redirect_to :signup, params: { c: true }
  end

  def confirmation
    confirmation_link = NewslettersConfirmationLink.find(params[:secret])
    if confirmation_link
      NewsletterSignupJob.perform_later(confirmation_link.email,
                                        confirmation_link.tags.map(&:to_sym))
      Rails.cache.delete(confirmation_link.cache_key)
      @confirmed = true
    else
      @confirmed = false
    end
  end
end

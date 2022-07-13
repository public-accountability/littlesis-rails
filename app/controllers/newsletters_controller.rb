# frozen_string_literal: true

class NewslettersController < ApplicationController
  def status
  end

  def email_status
    RateLimiter.rate_limit "newsletter_email_count/#{request.remote_ip}"

    # send email...

    redirect_to newsletters_status_path(submitted: true)
  end
end

# frozen_string_literal: true

class SystemMailerPreview < ActionMailer::Preview
  def metrics_email
    SystemMailer.metrics_email
  end
end

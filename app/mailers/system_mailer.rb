# frozen_string_literal: true

class SystemMailer < ApplicationMailer
  default to: APP_CONFIG['notification_to']

  def metrics_email(time = 1.day)
    @metrics = WebRequestMetrics.new(time: time)
    mail(subject: "LittleSis Request Metrics")
  end
end

# frozen_string_literal: true

class SystemMailer < ApplicationMailer
  default to: APP_CONFIG['notification_to']

  def metrics_email(time = 1.day)
    @request_metrics = WebRequestMetrics.new(time: time)
    @record_metrics = NewRecordMetrics.new(@request_metrics.then, @request_metrics.now)
    mail(subject: 'LittleSis Request Metrics')
  end
end

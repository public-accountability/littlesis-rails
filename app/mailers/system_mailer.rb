# frozen_string_literal: true

class SystemMailer < ApplicationMailer
  default to: Rails.application.config.littlesis[:notification_to]

  def metrics_email(time = 1.day)
    @request_metrics = WebRequestMetrics.new(time: time)
    @record_metrics = NewRecordMetrics.new(@request_metrics.then, @request_metrics.now)
    @active_users = User.active_users(since: time.ago, per_page: 10)
    mail(subject: 'LittleSis Request Metrics')
  end
end

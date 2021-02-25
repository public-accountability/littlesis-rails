# frozen_string_literal: true

class UserFlag < UserRequest
  validates :page, presence: true

  after_create :send_notification_email

  def approve!
    true
  end

  def email
    self[:email] || user.email
  end

  private

  def send_notification_email
    NotificationMailer.flag_email(self)
  end
end

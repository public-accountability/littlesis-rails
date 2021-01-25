# frozen_string_literal: true

class ContactForm
  include ActiveModel::Model
  include FormMathCaptcha

  attr_accessor :name, :email, :subject, :message, :very_important_wink_wink

  validates :name, :message, :email, presence: true

  validate :not_spam

  private

  def not_spam
    errors.add(:base, ErrorsController::YOU_ARE_SPAM) if very_important_wink_wink.present?
    errors.add(:base, ErrorsController::YOU_ARE_SPAM) if SpamDetector.mostly_cyrillic?(message)
  end
end

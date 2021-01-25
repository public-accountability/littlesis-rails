# frozen_string_literal: true

class NewsletterSignupForm
  include ActiveModel::Model

  attr_accessor :email, :very_important_wink_wink

  validates :email, presence: true

  validate :not_spam

  private

  def not_spam
    errors.add(:base, ErrorsController::YOU_ARE_SPAM) if very_important_wink_wink.present?
  end
end

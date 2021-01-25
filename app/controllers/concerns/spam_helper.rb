# frozen_string_literal: true

module SpamHelper
  protected

  def likely_a_spam_bot
    params['very_important_wink_wink'].present?
  end
end

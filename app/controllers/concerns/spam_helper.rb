# frozen_string_literal: true

module SpamHelper
  protected

  def likely_a_spam_bot
    params['very_important_wink_wink'].present?
  end

  def math_captcha
    @math_captcha ||= MathCaptcha.new
  end

  def verify_math_captcha
    MathCaptcha.correct?(**params
                             .require(:math)
                             .permit(:number_one, :number_two, :operation, :answer)
                             .to_h
                             .symbolize_keys)
  end
end

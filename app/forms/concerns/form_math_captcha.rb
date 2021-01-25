module FormMathCaptcha
  extend ActiveSupport::Concern

  included do
    attr_accessor :math_captcha_first, :math_captcha_second, :math_captcha_operation,
      :math_captcha_answer

    validate :correct_captcha
  end

  def math_captcha
    @math_captcha ||= MathCaptcha.new
  end

  private

  def correct_captcha
    errors.add(:base, 'Incorrect solution to the math problem. Please try again.') unless verify_math_captcha
  end

  def verify_math_captcha
    math_captcha_answer.present? && MathCaptcha.correct?(
      number_one: math_captcha_first,
      number_two: math_captcha_second,
      operation: math_captcha_operation,
      answer: math_captcha_answer
    )
  end
end

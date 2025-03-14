require 'net/http'

module FormHcaptcha
  extend ActiveSupport::Concern

  def verify_hcaptcha(response)
    uri = URI('https://hcaptcha.com/siteverify')
    res = Net::HTTP.post_form(uri, 'secret' => Rails.application.config.littlesis.hcaptcha_secret_key,
                                   'response' => response[:'g-recaptcha-response'])

    response_data = JSON.parse(res.body)

    return if ActiveModel::Type::Boolean.new.cast(response_data['success'])

    flash[:alert] = 'hCaptcha could not be verified. Please try again.'

  end
end


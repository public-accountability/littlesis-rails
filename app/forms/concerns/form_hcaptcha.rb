require 'net/http'

module FormHcaptcha
  extend ActiveSupport::Concern

  def verify_hcaptcha(response)
    return true if !Rails.env.production?

    uri = URI('https://hcaptcha.com/siteverify')
    res = Net::HTTP.post_form(uri, 'secret' => Rails.application.config.littlesis.hcaptcha_secret_key,
                                   'response' => response[:'g-recaptcha-response'])

    res_body = JSON.parse(res.body)

    return ActiveModel::Type::Boolean.new.cast(res_body['success'])
  end
end


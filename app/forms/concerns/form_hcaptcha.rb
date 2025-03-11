require 'net/http'

module FormHcaptcha
  extend ActiveSupport::Concern

  def verify(params)
    uri = URI('https://hcaptcha.com/siteverify')
    res = Net::HTTP.post_form(uri, 'secret' => Rails.application.credentials.hcaptcha_secret_key,
                                   'response' => params['g-recaptcha-response'])

    response_data = JSON.parse(res.body)

    return if ActiveModel::Type::Boolean.new.cast(response_data['success'])

    flash[:errors] = 'hCaptcha could not be verified.'
    redirect_to request.referrer || root_path
  end
end


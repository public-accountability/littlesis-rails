require 'net/http'

module FormHcaptcha
  extend ActiveSupport::Concern

  included do
    attr_accessor :user_signed_in

    validate :verify, :unless => :user_signed_in
  end

  def verify(params)
    uri = URI('https://hcaptcha.com/siteverify')
    res = Net::HTTP.post_form(uri, 'secret' => Rails.application.credentials.hcaptcha_secret_key,
                                   'response' => params['g-recaptcha-response'])

    response_data = JSON.parse(res.body)

    return if ActiveModel::Type::Boolean.new.cast(response_data['success'])

    flash[:notice] = 'hCaptcha could not be verify.'
    redirect_to request.referrer || root_path
  end
end


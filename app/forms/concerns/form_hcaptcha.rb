require 'net/http'

module FormHcaptcha
  extend ActiveSupport::Concern

  def verify(params)
    # Include a test response if we're in testing mode
    if Rails.application.config.littlesis.hcaptcha_site_key == '10000000-ffff-ffff-ffff-000000000001'
      params['g-recaptcha-response'] = "10000000-aaaa-bbbb-cccc-000000000001";
    end

    uri = URI('https://hcaptcha.com/siteverify')
    res = Net::HTTP.post_form(uri, 'secret' => Rails.application.config.littlesis.hcaptcha_secret_key,
                                   'response' => params['g-recaptcha-response'])

    response_data = JSON.parse(res.body)

    return if ActiveModel::Type::Boolean.new.cast(response_data['success'])

    flash[:errors] = 'hCaptcha could not be verified.'
    redirect_to request.referrer || root_path
  end
end


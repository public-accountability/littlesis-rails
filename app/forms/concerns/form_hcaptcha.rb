require 'net/http'

module FormHcaptcha
  extend ActiveSupport::Concern

  included do
     attr_accessor :g_recaptcha_response, :user_signed_in

     validate :correct_captcha, :unless => :user_signed_in
   end

  private

  def correct_captcha
    errors.add(:base, 'hCaptcha could not be verified. Please try again.') unless verify_hcaptcha
  end

  def verify_hcaptcha
    # Include a test response if we're in testing mode
    if Rails.application.config.littlesis.hcaptcha_site_key == '10000000-ffff-ffff-ffff-000000000001'
      @g_recaptcha_response = "10000000-aaaa-bbbb-cccc-000000000001";
    end

    uri = URI('https://hcaptcha.com/siteverify')
    res = Net::HTTP.post_form(uri, 'secret' => Rails.application.config.littlesis.hcaptcha_secret_key,
                                   'response' => @g_recaptcha_response)

    response_data = JSON.parse(res.body)

    return response_data['success']
  end
end


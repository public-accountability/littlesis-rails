Recaptcha.configure do |config|
  config.site_key  = APP_CONFIG.fetch('recaptcha').fetch('site_key')
  config.secret_key = APP_CONFIG.fetch('recaptcha').fetch('secret_key')
end

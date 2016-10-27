Lilsis::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local  = true
  
  # Don't care if the mailer can't send.
  # config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  config.log_level = :debug
  config.log_formatter = ::Logger::Formatter.new
  
# Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  config.assets.debug = true

  # Disable caching for development
  config.action_controller.perform_caching = true
  config.cache_store = :memory_store
  
  # In development, links in emails should point local
  # config.action_mailer.default_url_options = { host: 'lilsis.local' }

  config.action_mailer.default_url_options = { :host => "littlesis.org" }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.smtp_settings = {
    address:              Lilsis::APP_CONFIG['smtp_address'],
    port:                 Lilsis::APP_CONFIG['smtp_port'],
    domain:               Lilsis::APP_CONFIG['smtp_domain'],
    user_name:            Lilsis::APP_CONFIG['smtp_user_name'],
    password:             Lilsis::APP_CONFIG['smtp_password'],
    authentication:       Lilsis::APP_CONFIG['smtp_authentication'],
    ssl: true 
  }


  # Enable serving of images from asset server.
  config.action_controller.asset_host = Proc.new do |source|
    if source =~ /images/
      "//#{config.asset_host}"
    else
      nil
    end
  end
end

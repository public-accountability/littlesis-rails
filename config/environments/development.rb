# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = true
  config.action_controller.enable_fragment_cache_logging = true

  # config.cache_store = :redis_cache_store, { url: APP_CONFIG.fetch(:redis_url) }
  # config.cache_store = :redis_store #, "redis://redis:6379/0/cache"

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local
  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  config.assets.css_compressor = :sass

  # Debug mode disables concatenation and preprocessing of assets.
  config.assets.debug = true
  config.assets.quiet = true

  # Raises error for missing translations
  config.action_view.raise_on_missing_translations = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  config.log_level = :debug
  config.log_formatter = ::Logger::Formatter.new

  config.active_record.verbose_query_logs = true

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  config.action_mailer.default_url_options[:host] = 'localhost:8080'
  config.action_mailer.default_url_options[:protocol] = 'http'
  config.action_mailer.perform_deliveries = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.smtp_settings = {
    address:              APP_CONFIG['smtp_address'],
    port:                 APP_CONFIG['smtp_port'],
    domain:               APP_CONFIG['smtp_domain'],
    user_name:            APP_CONFIG['smtp_user_name'],
    password:             APP_CONFIG['smtp_password'],
    authentication:       APP_CONFIG['smtp_authentication'],
    ssl: true
  }

  config.active_storage.service = :local

  # see: https://github.com/rails/web-console for info on web_console configuration
  config.web_console.allowed_ips = ['172.0.0.0/8']
  config.web_console.whiny_requests = false

  # TODO: Maybe enable this?
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end

# frozen_string_literal: true

Rails.application.configure do
  config.hosts << 'app'
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = true
  config.action_controller.enable_fragment_cache_logging = true

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Debug mode disables concatenation and preprocessing of assets.
  config.assets.debug = false
  config.assets.digest = false
  config.assets.quiet = false
  config.assets.css_compressor = nil

  # Raises error for missing translations
  config.i18n.raise_on_missing_translations = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  config.log_level = :debug
  config.log_formatter = ::Logger::Formatter.new

  config.active_record.verbose_query_logs = true

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  config.action_mailer.perform_caching = false
  config.action_mailer.preview_path = Rails.root.join("spec/mailers/previews")

  config.action_mailer.delivery_method = :file
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true

  # save mail in tmp/mail
  config.action_mailer.file_settings = { location: Rails.root.join('tmp/mail') }
  config.active_storage.service = :local

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  # config.action_cable.disable_request_forgery_protection = true

  # see: https://github.com/rails/web-console for info on web_console configuration
  config.web_console.allowed_ips = ['172.0.0.0/8']
  config.web_console.whiny_requests = false

  config.good_job.execution_mode = :external
  # config.good_job.enable_cron = true
  # config.good_job.max_threads = 1
end

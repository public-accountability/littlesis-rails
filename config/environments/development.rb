Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # see: https://github.com/rails/web-console for info on web_console configuruation
  config.web_console.whitelisted_ips = ['172.21.0.0/16', '172.19.0.0/16']
  config.web_console.whiny_requests = false

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local = true

   # Enable/disable caching. By default caching is disabled.
   # Run rails dev:cache to toggle caching.
  # if Rails.root.join('tmp', 'caching-dev.txt').exist?
  #   config.action_controller.perform_caching = true

  #   config.cache_store = :memory_store
  #   config.public_file_server.headers = {
  #     'Cache-Control' => "public, max-age=#{2.days.to_i}"
  #   }
  # else
  #   config.action_controller.perform_caching = false

  #   config.cache_store = :null_store
  # end

  config.action_controller.perform_caching = true

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
  # config.action_controller.asset_host = '/'

  # config.action_controller.asset_host = Proc.new do |source|
  #   if source =~ /images/
  #     "https://#{config.asset_host}"
  #   else
  #     nil
  #   end
  # end

  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end

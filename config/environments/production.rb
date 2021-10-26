# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both thread web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.public_file_server.enabled = false

  # Compress CSS
  config.assets.css_compressor = :sass

  # Whether to fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Set to :debug to see everything in the log.
  config.log_level = :info
  config.log_tags = []

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # possibly needed to ensure that FOG_DIRECTORY is initialized
  # TODO: is this needed?
  config.assets.initialize_on_precompile = true

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  config.action_controller.asset_host = "https://#{config.littlesis[:asset_host]}"
  config.assets.prefix = '/assets'

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_deliveries = !config.littlesis.beta
  config.action_mailer.smtp_settings = {
    address:              config.littlesis[:smtp_address],
    port:                 config.littlesis[:smtp_port],
    domain:               config.littlesis[:smtp_domain],
    user_name:            config.littlesis[:smtp_user_name],
    password:             config.littlesis[:smtp_password],
    authentication:       config.littlesis[:smtp_authentication],
    ssl: true
  }

  # config.i18n.fallbacks = [I18n.default_locale]
  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify
end

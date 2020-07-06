require_relative 'boot'

require 'rails/all'

# Assets should be precompiled for production (so we don't need the gems loaded then)
Bundler.require(*Rails.groups)

module Lilsis
  APP_CONFIG = YAML.load(ERB.new(File.new("#{Dir.getwd}/config/lilsis.yml").read).result)[Rails.env]

  class Application < Rails::Application
    config.load_defaults 5.0
    config.autoloader = :classic
    #config.autoloader = :zeitwerk

    config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do
      rewrite  %r{\A/(person|org)/([0-9]+)/[^/ ]+(/.*)?}, '/entities/$2$3'
      rewrite  %r{\A/(person|org)/(.*)},                  '/entities/$2'
      r301     %r{^/(beginnerhelp|advancedhelp)$},      '/help'
      r301     %r{/user/(.*)},                          '/users/$1'
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    APP_CONFIG.each_pair { |k,v| config.send :"#{k}=", v }

    # In production this does nothing: /lib is NOT loaded in production
    # However, constants in /lib will be loaded, lazily in development and test environments
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/lib/importers)

    config.cache_store = :redis_cache_store, { url: APP_CONFIG.fetch('redis_url') }

    if Rails.env.production?
      Rails.application.default_url_options[:host] = 'littlesis.org'
      Rails.application.default_url_options[:protocol] = 'https'
    else
      Rails.application.default_url_options[:protocol] = 'http'
      Rails.application.default_url_options[:host] = 'localhost:8080'
    end

    config.action_mailer.default_url_options = { :host => "littlesis.org" }
    # config.action_mailer.delivery_method = :sendmail
    # config.action_mailer.raise_delivery_errors = true
    # config.action_mailer.perform_deliveries = true

    # config.action_controller.asset_host = APP_CONFIG['site_url']

    config.assets.paths << "#{Rails.root}/vendor/assets/images"

    config.active_job.queue_adapter = :delayed_job

    # we can't check only check if requests come from 'littlesis.org'
    # because the chrome extension is allowed to also make requests
    config.action_controller.forgery_protection_origin_check = false
  end
end

ActiveRecord::SessionStore::Session.serializer = :json

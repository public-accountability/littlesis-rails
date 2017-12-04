require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Assets should be precompiled for production (so we don't need the gems loaded then)
Bundler.require(*Rails.groups(assets: %w(development test)))

module Lilsis
  APP_CONFIG = YAML.load(ERB.new(File.new("#{Dir.getwd}/config/lilsis.yml").read).result)[Rails.env]

  class Application < Rails::Application

    config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do
      rewrite  %r{/(person|org)/([0-9]+)/[^/ ]+(/.*)?}, '/entities/$2$3'
      rewrite  %r{/(person|org)/(.*)},                  '/entities/$2'
      rewrite  %r{/(person|org)/(.*)},                  '/entities/$2'
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

    config.autoload_paths += %W(#{config.root}/lib)

    config.cache_store = :redis_store

    if Rails.env.production?
      Rails.application.default_url_options[:host] = 'littlesis.org'
      Rails.application.default_url_options[:protocol] = 'https'
    else
      Rails.application.default_url_options[:host] = 'localhost:8080'
    end

    config.action_mailer.default_url_options = { :host => "littlesis.org" }
    # config.action_mailer.delivery_method = :sendmail
    # config.action_mailer.raise_delivery_errors = true
    # config.action_mailer.perform_deliveries = true

    config.assets.paths << "#{Rails.root}/vendor/assets/images"

    config.tinymce.install = :copy

    config.active_record.raise_in_transactional_callbacks = true

    config.active_job.queue_adapter = :delayed_job

    @twitter = Twitter::REST::Client.new do |cnf|
      cnf.consumer_key        = config.twitter_consumer_key
      cnf.consumer_secret     = config.twitter_consumer_secret
      cnf.access_token        = config.twitter_access_token
      cnf.access_token_secret = config.twitter_access_token_secret
    end

    def self.twitter
      @twitter
    end
  end
end

ActiveRecord::SessionStore::Session.serializer = :json

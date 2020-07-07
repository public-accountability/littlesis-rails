# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'

# Assets should be precompiled for production (so we don't need the gems loaded then)
Bundler.require(*Rails.groups)

APP_CONFIG = YAML.load(
  ERB.new(File.new("#{Dir.getwd}/config/lilsis.yml").read).result
).fetch(Rails.env).with_indifferent_access.freeze

module Lilsis
  class Application < Rails::Application
    config.load_defaults 5.0
    config.autoloader = :classic
    # config.autoloader = :zeitwerk

    config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do
      rewrite  %r{\A/(person|org)/([0-9]+)/[^/ ]+(/.*)?}, '/entities/$2$3'
      rewrite  %r{\A/(person|org)/(.*)},                  '/entities/$2'
      r301     %r{^/(beginnerhelp|advancedhelp)$},      '/help'
      r301     %r{/user/(.*)},                          '/users/$1'
    end

    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # APP_CONFIG.each_pair { |k,v| config.send :"#{k}=", v }

    config.cache_store = :redis_cache_store, { url: APP_CONFIG.fetch('redis_url') }

    config.action_mailer.default_url_options = { :host => "littlesis.org" }

    # config.action_controller.asset_host = APP_CONFIG['site_url']

    config.assets.paths << "#{Rails.root}/vendor/assets/images"

    config.active_job.queue_adapter = :delayed_job

    # we can't check only check if requests come from 'littlesis.org'
    # because the chrome extension is allowed to also make requests
    config.action_controller.forgery_protection_origin_check = false
  end
end

ActiveRecord::SessionStore::Session.serializer = :json

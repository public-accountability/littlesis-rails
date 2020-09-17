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
      r301     %r{^/(beginnerhelp|advancedhelp)$},        '/help'
      r301     %r{/user/(.*)},                            '/users/$1'
    end

    default_url_options = {
      host: APP_CONFIG.fetch('host', 'littlesis.org'),
      protocol: APP_CONFIG.fetch('protocol', 'https')
    }

    Lilsis::Application.default_url_options = default_url_options
    config.action_controller.default_url_options = default_url_options
    config.action_mailer.default_url_options = default_url_options

    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc
    # Since Rails 6 `belongs_to` associations are by default
    config.active_record.belongs_to_required_by_default = false

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]

    # /lib is not loaded in production
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/lib/importers)

    config.cache_store = :redis_cache_store, { url: APP_CONFIG.fetch('redis_url') }

    config.assets.paths << "#{Rails.root}/vendor/assets/images"
    config.active_job.queue_adapter = :delayed_job

    config.action_controller.per_form_csrf_tokens = false

    # we can't require only requests from 'littlesis.org'
    # because the chrome extension is allowed to also make requests
    config.action_controller.forgery_protection_origin_check = false

    # Make `form_with` generate non-remote forms.
    config.action_view.form_with_generates_remote_forms = false
  end
end

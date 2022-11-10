# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'
require 'good_job/engine'

# Assets should be precompiled for production (so we don't need the gems loaded then)
Bundler.require(*Rails.groups)

module LittleSis
  class Application < Rails::Application
    config.littlesis = config_for(:littlesis)

    config.load_defaults 7.0

    config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do
      r301     %r{^/(beginnerhelp|advancedhelp)$},        '/help'
      r301     %r{/user/(.*)},                            '/users/$1'
    end

    Rails.application.default_url_options = {
      host: config.littlesis.fetch(:host, 'littlesis.org'),
      protocol: config.littlesis.fetch(:protocol, 'https')
    }

    routes.default_url_options = Rails.application.default_url_options
    config.action_controller.default_url_options = Rails.application.default_url_options
    config.action_mailer.default_url_options = Rails.application.default_url_options

    config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc

    # Since Rails 6 `belongs_to` associations are by default
    config.active_record.belongs_to_required_by_default = false

    # see https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017
    #     https://github.com/paper-trail-gem/paper_trail/pull/1397
    config.active_record.yaml_column_permitted_classes = [
      Symbol,
      BigDecimal,
      Date,
      Time,
      ActiveRecord::Type::Time::Value,
      ActiveSupport::TimeWithZone,
      ActiveSupport::TimeZone
    ]

    config.i18n.fallbacks = [:en]

    config.cache_store = :redis_cache_store, { url: config.littlesis[:redis_url] }

    # config.assets.paths << "#{Rails.root}/vendor/assets/images"
    config.active_job.queue_adapter = :good_job

    config.action_controller.per_form_csrf_tokens = false

    # we can't require only requests from 'littlesis.org'
    # because the chrome extension is allowed to also make requests
    config.action_controller.forgery_protection_origin_check = false

    # Make `form_with` generate non-remote forms.
    config.action_view.form_with_generates_remote_forms = false

    config.active_storage.draw_routes = true

    config.active_record.schema_format = :sql

    config.assets.css_compressor = :sass
    config.assets.js_compressor = false

    config.generators do |g|
      g.test_framework :rspec, view_specs: false, controller_specs: true
    end

    config.action_mailer.default_options = {
      from: 'email.robot@littlesis.org',
      reply_to: 'admin@littlesis.org'
    }

    config.good_job.enable_cron = true

    config.good_job.cron = {
      update_link_counts: {
        cron: "30 4 * * *", # at 4:30am every day
        class: "UpdateEntityLinkCountJob",
        description: "Update Entity.link_count"
      }
    }

    # network_map_missing_screenshot: {
    #   cron: "30 6 * * *", # at 6:30am every day
    #   class: "OligrapherScreenshotSchedulingJob",
    #   args: [:missing],
    #   description: "Schedule jobs for network Maps missing screenshots"
    # },
  end
end

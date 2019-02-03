# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tracker
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Schema has to be in SQL format because we are using PG Enums which are not supported by the default ruby format
    config.active_record.schema_format = :sql

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.autoload_paths += %W[#{config.root}/lib]

    # Google OAuth settings
    config.google_client_id = ENV['GOOGLE_CLIENT_ID']
    config.google_client_secret = ENV['GOOGLE_CLIENT_SECRET']
    config.google_token_info_url = 'https://www.googleapis.com/oauth2/v3/tokeninfo'

    config.log_tags = {
      request_id: :request_id
    }
    config.log_level = :info

    config.rails_semantic_logger.define_singleton_method(:filter) { nil } # Fix for Semantic Logger having the filter method which overrides Ruby #filter
  end
end

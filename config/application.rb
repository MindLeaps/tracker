require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tracker
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Google OAuth settings
    config.google_client_id = ENV.fetch('GOOGLE_CLIENT_ID', nil)
    config.google_client_secret = ENV.fetch('GOOGLE_CLIENT_SECRET', nil)
    config.google_token_info_url = 'https://www.googleapis.com/oauth2/v3/tokeninfo'

    config.log_tags = {
      request_id: :request_id
    }
    config.log_level = :info
  end
end

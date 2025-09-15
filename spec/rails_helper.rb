# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'view_component/test_helpers'
require 'rspec/rails'
require 'pundit/rspec'
require 'webmock/rspec'
require 'devise'
require 'database_cleaner/active_record'
require 'rspec/retry'

WebMock.disable_net_connect!(allow: ['localhost', '127.0.0.1', 'chromedriver.storage.googleapis.com'], net_http_connect_on_start: true)

Rails.root.glob('spec/test_helpers/**/*.rb').each { |f| require f }
Rails.root.glob('spec/shared/**/*.rb').each { |f| require f }
Rails.root.glob('spec/support/**/*.rb').each { |f| require f }
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include ViewComponent::TestHelpers, type: :component
  config.include FactoryBot::Syntax::Methods
  config.include Helpers
  config.include ApplicationHelper

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with :truncation
    # FactoryBot.lint

    # Clean tmp/uploads before each run
    FileUtils.rm_rf(Dir[Rails.root.join('tmp/storage').to_s])
    FileUtils.rm_rf(Dir[Rails.root.join('tmp/screenshots').to_s])
    FileUtils.rm_rf(Rails.root.join('tmp/capybara'))
    FileUtils.rm_rf(Dir[Rails.public_path.join('assets').to_s])
  end

  config.before(:each) do
    FactoryBot.rewind_sequences
    Capybara.raise_server_errors = true
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Ensure tmp files are cleared after each example
  config.after(:each) do
    FileUtils.rm_rf(Dir[Rails.root.join('tmp/storage/*').to_s])
  end

  # Retry configuration
  config.verbose_retry = true
  config.display_try_failure_messages = true
  config.default_retry_count = 2

  # Setup Bullet for detecting N+1 queries
  if Bullet.enable?
    config.before(:each) do
      Bullet.start_request
    end

    config.after(:each) do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end

    config.around(:each, type: :model) do |example|
      Bullet.unused_eager_loading_enable = false
      example.run
      Bullet.unused_eager_loading_enable = true
    end

    config.around(:each, type: :controller) do |example|
      Bullet.unused_eager_loading_enable = false
      example.run
      Bullet.unused_eager_loading_enable = true
    end

    config.around(:each, type: :feature) do |example|
      Bullet.unused_eager_loading_enable = false
      example.run
      Bullet.unused_eager_loading_enable = true
    end

    config.around(:each, type: :request) do |example|
      Bullet.unused_eager_loading_enable = false
      example.run
      Bullet.unused_eager_loading_enable = true
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.1.4'
# Use postgres as the database for Active Record
gem 'pg', '0.21.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'devise'
gem 'omniauth-google-oauth2'
gem 'pundit'
gem 'rolify'
gem 'tiddle'

gem 'active_model_serializers', '~> 0.10.0'
gem 'carrierwave', '~> 1.0'
gem 'carrierwave-bombshelter'
gem 'carrierwave-imageoptimizer'
gem 'cocoon'
gem 'enum_help'
gem 'fog-aws'
gem 'has_scope'
gem 'inline_svg'
gem 'mini_magick'
gem 'puma'
gem 'simple_form'
gem 'skylight'
gem 'slim'

gem 'mindleaps_analytics', path: ENV['MINDLEAPS_ANALYTICS_PATH'] if ENV['MINDLEAPS_ANALYTICS_PATH']

group :production do
  gem 'newrelic_rpm'
  gem 'SyslogLogger'
end

group :development, :test do
  gem 'bullet'
  gem 'rails-controller-testing'
  gem 'rubocop'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Rspec requires capybara > 2.1
  gem 'capybara', '> 2.1'
  gem 'chromedriver-helper'
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'poltergeist'
  gem 'pundit-matchers'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'smarter_csv'
  gem 'webmock'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'dotenv-rails'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'pry'
  gem 'spring'
end

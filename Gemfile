source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.2'
# Use postgres as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'omniauth-google-oauth2'
gem 'devise'
gem 'tiddle'
gem 'rolify'
gem 'pundit'

gem 'simple_form'
gem 'enum_help'
gem 'bootstrap', '~> 4.0.0.alpha3.1'
gem 'cocoon'
gem 'jquery-rails'
gem 'active_model_serializers', '~> 0.10.0'
gem 'has_scope'
gem 'carrierwave', '~> 1.0'
gem 'carrierwave-bombshelter'
gem 'carrierwave-imageoptimizer'
gem 'fog-aws'
gem 'mini_magick'
gem 'puma'
gem 'skylight'

# gem 'mindleaps_analytics', path: '../Tracker-Analytics'

group :production do
  gem 'SyslogLogger'
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'rails-controller-testing'
  gem 'rubocop'
  gem 'bullet'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Rspec requires capybara > 2.1
  gem 'capybara', '> 2.1'
  gem 'rspec-rails'
  gem 'poltergeist'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'database_cleaner'
  gem 'pundit-matchers'
  gem 'shoulda-matchers'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
  gem 'coveralls', require: false
  gem 'webmock'
end

group :development do
  gem 'dotenv-rails'
  gem 'better_errors'
  gem 'binding_of_caller'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'pry'
end

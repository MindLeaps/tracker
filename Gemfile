# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails'
# Use postgres as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

gem 'devise'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'pundit'
gem 'rolify'
gem 'tiddle'

gem 'amazing_print'
gem 'rails_semantic_logger'

gem 'active_model_serializers', '~> 0.10.12'
gem 'bootsnap'
gem 'carrierwave'
gem 'carrierwave-bombshelter'
gem 'carrierwave-imageoptimizer'
gem 'cocoon'
gem 'enum_help'
gem 'fog-aws'
gem 'has_scope'
gem 'i18n_data'
gem 'inline_svg'
gem 'marginalia'
gem 'mini_magick'
gem 'pagy'
gem 'pghero'
gem 'pg_query', '>= 0.9.0'
gem 'pg_search'
gem 'puma'
gem 'rails-i18n'
gem 'scenic'
gem 'simple_form'
gem 'skylight'
gem 'slim'
gem 'sort_alphabetical'
gem 'turbolinks'
gem 'view_component', require: 'view_component/engine'
gem 'webpacker'

group :production do
  gem 'newrelic_rpm'
  gem 'SyslogLogger'
end

group :development, :test do
  gem 'apparition'
  gem 'bullet', '!= 6.0.0' # 6.0.0 seems to break with Turbolinks
  gem 'rails-controller-testing'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Rspec requires capybara > 2.1
  gem 'capybara', '> 2.1'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'json_matchers'
  gem 'pundit-matchers'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'smarter_csv'
  gem 'webdrivers'
  gem 'webmock'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'dotenv-rails'
  gem 'web-console' # Access an IRB console on exception pages or by using <%= console %> in views

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'pry'
  gem 'spring'
end

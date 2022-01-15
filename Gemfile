# frozen_string_literal: true

source 'https://rubygems.org'

gem 'active_model_serializers'
gem 'amazing_print'
gem 'bootsnap'
gem 'carrierwave'
gem 'carrierwave-bombshelter'
gem 'carrierwave-imageoptimizer'
gem 'cocoon'
gem 'devise'
gem 'enum_help'
gem 'fog-aws'
gem 'has_scope'
gem 'i18n_data'
gem 'importmap-rails'
gem 'inline_svg'
gem 'marginalia'
gem 'mini_magick'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'pagy'
gem 'pg'
gem 'pghero'
gem 'pg_query', '>= 0.9.0'
gem 'pg_search'
gem 'puma'
gem 'pundit'
gem 'rails'
gem 'rails-i18n'
gem 'rails_semantic_logger'
gem 'rolify'
gem 'scenic'
gem 'simple_form'
gem 'skylight'
gem 'slim'
gem 'sort_alphabetical'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'tailwindcss-rails'
gem 'tiddle'
gem 'view_component'

group :production do
  gem 'newrelic_rpm'
  gem 'SyslogLogger'
end

group :development, :test do
  gem 'apparition', github: 'twalpole/apparition', ref: 'ca86be4d54af835d531dbcd2b86e7b2c77f85f34'
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
  gem 'annotate', github: 'dabit/annotate_models', branch: 'rails-7'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'dotenv-rails'
  gem 'web-console' # Access an IRB console on exception pages or by using <%= console %> in views

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'pry'
  gem 'solargraph'
  gem 'spring'
end

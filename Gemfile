source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.0.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'omniauth-google-oauth2'
gem 'devise'
gem 'rolify'
gem 'pundit'

gem 'simple_form'
gem 'enum_help'
gem 'bootstrap', '~> 4.0.0.alpha3.1'
gem 'cocoon'
gem 'jquery-rails'

group :production do
  gem 'puma'
  gem 'SyslogLogger'
end

group :development, :test do
  gem 'rails-controller-testing'
  gem 'rubocop'
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
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'pry'
end

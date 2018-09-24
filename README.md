# MindLeaps Tracker
[![Build Status](https://travis-ci.org/MindLeaps/tracker.svg?branch=master)](https://travis-ci.org/MindLeaps/tracker) [![security](https://hakiri.io/github/MindLeaps/tracker/master.svg)](https://hakiri.io/github/MindLeaps/tracker/master)
[![Coverage Status](https://coveralls.io/repos/github/MindLeaps/tracker/badge.svg?branch=master)](https://coveralls.io/github/MindLeaps/tracker?branch=master)

This software is responsible for keeping track of Students in the field and their progress in MindLeaps programs.

## Getting started

1. We need GPG for RVM installation so on Mac install it via Brew:
    ```sh
    brew install gnupg
    ```

2. Install [rvm](https://rvm.io/)
    ```sh
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    curl -sSL https://get.rvm.io | bash -s stable
    ```

3. Clone the Repo
    ```sh
    git clone https://github.com/MindLeaps/tracker.git
    ```
    
4. Install Ruby version required by MindLeaps Tracker
    ```bash
    cd tracker
    rvm install `cat ./.ruby-version`
    ```

5. Install Bundler
    ```sh
    gem install bundler
    ```
    
6. Install all gems
    ```sh
    bundle install
    ```
    
7. Install Postgres and Phantomjs. On OS X you can use [brew](http://brew.sh/)
    ```sh
    brew install postgresql
    brew install phantomjs
    ```

8. Create and seed the database
    ```sh
    rake db:create
    rake db:seed
    ```

9. Uncomment the following in BaseController to skip auth in development

    ```
    /app/controllers/base_controller.rb
    
      # Uncomment this to skip authentication in development
      # def authenticate_user!
      #   return true if Rails.env.development?
      #
      #   raise SecurityError
      # end
      #
      # def current_user
      #   raise SecurityError unless Rails.env.development?
      #
      #   user = User.find_or_create_by!(email: 'test@example.com')
      #   user.add_role :super_admin
      #   user
      # end
    ```
    
10. Start the app with
    ```sh
        > rails s
    ```
    
11. Alternatively, if you have google authentication set up, you don't have to skip authentication and Start the rails server with Google client ID and secret in the environment for OAuth.
    ```sh
    GOOGLE_CLIENT_ID={your_google_client_id} GOOGLE_CLIENT_SECRET={your_google_client_secret} rails s
    ``` 
    
Finally, point your browser to http://localhost:3000

You can test the application by running:
```sh
rake test
```

## Running MindLeaps Tracker with Analytics

Analytics engine is located in a separate repository:

1. Clone the Analytics repository (put it somewhere outside of tracker repo): https://github.com/MindLeaps/Tracker-Analytics

2. Start Tracker by running

    ```sh
        MINDLEAPS_ANALYTICS_PATH={path to where you cloned analytics repo} bundle exec rails s
    ```

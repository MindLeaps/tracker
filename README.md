# Mindleaps Tracker
[![Build Status](https://travis-ci.org/MindLeaps/tracker.svg?branch=master)](https://travis-ci.org/MindLeaps/tracker) [![security](https://hakiri.io/github/MindLeaps/tracker/master.svg)](https://hakiri.io/github/MindLeaps/tracker/master)
[![Coverage Status](https://coveralls.io/repos/github/MindLeaps/tracker/badge.svg?branch=master)](https://coveralls.io/github/MindLeaps/tracker?branch=master)

This software is responsible for keeping track of Students and Groups and for facilitating grading.

## Getting started

1. Install [rvm](https://rvm.io/)
    ```sh
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    curl -sSL https://get.rvm.io | bash -s stable
    ```

2. Clone the Repo
    ```sh
    git clone https://github.com/MindLeaps/tracker.git
    ```
    
3. Install Ruby version required by MindLeaps Tracker
    ```bash
    cd tracker
    rvm install `cat ./.ruby-version`
    ```

4. Install Bundler
    ```sh
    gem install bundler
    ```
    
5. Install all gems
    ```sh
    bundle install
    ```
    
6. Install Postgres and Phantomjs. On OS X you can use [brew](http://brew.sh/)
    ```sh
    brew install postgresql
    brew install phantomjs
    ```

7. Create and seed the database
    ```sh
    rake db:create
    rake db:seed
    ```

8. Start the rails server with Google client ID and secret in the environment for OAuth.
    ```sh
    GOOGLE_CLIENT_ID={your_google_client_id} GOOGLE_CLIENT_SECRET={your_google_client_secret} rails s
    ```
    
Finally, point your browser to http://localhost:3000

You can test the application by running:
```sh
rake test
```

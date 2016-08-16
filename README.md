# Mindleaps Tracker
[![Build Status](https://travis-ci.org/MindLeaps/tracker.svg?branch=master)] (https://travis-ci.org/MindLeaps/tracker) [![security](https://hakiri.io/github/MindLeaps/tracker/master.svg)](https://hakiri.io/github/MindLeaps/tracker/master) [![Dependency Status](https://gemnasium.com/badges/github.com/MindLeaps/tracker.svg)](https://gemnasium.com/github.com/MindLeaps/tracker) [![Code Climate](https://codeclimate.com/github/MindLeaps/tracker/badges/gpa.svg)](https://codeclimate.com/github/MindLeaps/tracker) [![Join the chat at https://gitter.im/MindLeaps/tracker](https://badges.gitter.im/MindLeaps/tracker.svg)](https://gitter.im/MindLeaps/tracker?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This software is responsible for keeping track of Students and Groups and for facilitating grading.

## Getting started

Things you'll need

    rbenv or rvm
    phantomjs

Put your Google OAuth client id and secret in development.rb config

```ruby
config.google_client_id = 'YOUR_CLIENT_ID'
config.google_client_secret = 'YOUR_CLIENT_SECRET'
```

Starting the server

```shell
bundle install
rails s # if you have configured Google OAuth in the development.rb config file
# if you haven't, or if you're in production then
GOOGLE_CLIENT_ID={your_google_client_id} GOOGLE_CLIENT_SECRET={your_google_client_secret} rails s
```

Then point your browser at http://localhost:3000

## Deployment

From the deploy directory:
```shell
ansible-playbook -i staging.ini playbook.yml
```
This will deploy to staging, and expects you have credentials for the machine.

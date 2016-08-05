# Mindleaps Tracker [![Build Status](https://travis-ci.org/MindLeaps/tracker.svg?branch=master)] (https://travis-ci.org/MindLeaps/tracker) [![security](https://hakiri.io/github/MindLeaps/tracker/master.svg)](https://hakiri.io/github/MindLeaps/tracker/master) [![Code Climate](https://codeclimate.com/github/MindLeaps/tracker/badges/gpa.svg)](https://codeclimate.com/github/MindLeaps/tracker) [![Join the chat at https://gitter.im/MindLeaps/tracker](https://badges.gitter.im/MindLeaps/tracker.svg)](https://gitter.im/MindLeaps/tracker?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This software is responsible for keeping track of Students and Groups and for facilitating grading.

## Getting started

Things you'll need

    rbenv or rvm
    phantomjs

Starting the server

    bundle install
    GOOGLE_CLIENT_ID={your_google_client_id} GOOGLE_CLIENT_SECRET={your_google_client_secret} rails s

Then point your browser at http://localhost:3000

## Deployment

From the deploy directory:

    ansible-playbook -i staging.ini playbook.yml

This will deploy to staging, and expects you have credentials for the machine.

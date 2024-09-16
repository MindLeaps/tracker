#!/bin/sh
set -e

bundle exec bin/rails db:create && bundle exec bin/rails db:migrate && bundle exec bin/rails server -b 0.0.0.0

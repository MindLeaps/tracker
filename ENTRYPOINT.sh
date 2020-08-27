#!/bin/bash
set -e

bundle exec bin/rake db:create && bundle exec bin/rake db:migrate && bundle exec bin/rails server -b 0.0.0.0

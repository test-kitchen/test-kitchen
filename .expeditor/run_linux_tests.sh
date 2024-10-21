#!/bin/bash
#
# This script runs a passed in command, but first setups up the bundler caching on the repo

set -ue

export USER="root"
export LANG=C.UTF-8 LANGUAGE=C.UTF-8

echo "--- bundle install"

bundle config --local path vendor/bundle
bundle install --jobs=7 --retry=3

echo "+++ bundle exec task"
bundle exec $@

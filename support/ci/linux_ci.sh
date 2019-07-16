#!/usr/bin/env bash

set -e

bundle exec rake
bundle install --with integration
bundle exec kitchen test
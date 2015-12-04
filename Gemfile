# -*- encoding: utf-8 -*-
source "https://rubygems.org"

gem "mixlib-install", github: "chef/mixlib-install", branch: "pw/windows"

gemspec

group :guard do
  gem "guard-minitest"
  gem "guard-cucumber", "~> 1.4"
  gem "guard-rubocop"
  gem "guard-yard"
end

group :test do
  gem "codeclimate-test-reporter", :require => nil
end

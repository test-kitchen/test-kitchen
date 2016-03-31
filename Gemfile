# -*- encoding: utf-8 -*-
source "https://rubygems.org"
gemspec

group :guard do
  gem "guard-minitest"
  gem "guard-cucumber", "~> 1.4"
  gem "guard-rubocop"
  gem "guard-yard"
end

group :integration do
  gem "berkshelf", "~> 4.3"
  gem "kitchen-inspec", "~> 0.12.5"
end

group :test do
  gem "codeclimate-test-reporter", :require => nil
end

# -*- encoding: utf-8 -*-
source "https://rubygems.org"
gemspec
gem "rack", "< 2.0"

gem "train", "~> 0.19.0"

group :integration do
  gem "berkshelf", "~> 4.3"
  gem "kitchen-inspec", "~> 0.15.1"
end

group :test do
  gem "codeclimate-test-reporter", :require => nil
end

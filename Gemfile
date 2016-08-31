# -*- encoding: utf-8 -*-
source "https://rubygems.org"
gemspec
gem "rack", "< 2.0"

gem "train", :github => "chef/train", :branch => "winrm-v2"

group :integration do
  gem "berkshelf", "~> 4.3"
  gem "kitchen-inspec", :git => "https://github.com/mwrock/kitchen-inspec", :branch => "winrm-v2"
end

group :test do
  gem "codeclimate-test-reporter", :require => nil
end

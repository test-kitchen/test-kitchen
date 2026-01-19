source "https://rubygems.org"

gemspec

group :test do
  gem "rake"
  gem "rb-readline"
  gem "aruba",     ">= 0.11", "< 3.0"
  gem "chef-cli"
  gem "countloc",  "~> 0.4"
  gem "cucumber",  ">= 9.2", "< 11"
  gem "fakefs",    "~> 3.0"
  gem "kitchen-inspec"
  gem "maruku",    "~> 0.7"
  gem "minitest",  "~> 5.3", "< 6.0"
  gem "mocha",     "~> 2.0"
end

group :integration do
  gem "kitchen-dokken"
  gem "kitchen-vagrant"
  gem "kitchen-inspec"
  gem "kitchen-omnibus-chef", git: "https://github.com/test-kitchen/kitchen-omnibus-chef", branch: "initial" # TODO: remove git refrence once https://github.com/test-kitchen/test-kitchen/pull/1 is merged
end

group :linting do
  gem "cookstyle", "~> 8.2"
end

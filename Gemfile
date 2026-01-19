source "https://rubygems.org"

gemspec

group :test do
  gem "rake"
  gem "rb-readline"
  gem "aruba",     ">= 0.11", "< 3.0"
  gem "countloc",  "~> 0.4"
  gem "cucumber",  ">= 9.2", "< 11"
  gem "fakefs",    "~> 3.0"
  gem "maruku",    "~> 0.7"
  gem "minitest",  "~> 6.0", "< 6.1"
  gem "mocha",     "~> 3.0"
end

group :integration do
  gem "chef-cli"
  gem "kitchen-dokken"
  gem "kitchen-vagrant"
  gem "kitchen-inspec"
  gem "kitchen-omnibus-chef"
end

group :linting do
  gem "cookstyle", "~> 8.2"
end

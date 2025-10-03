source "https://rubygems.org"

gemspec

group :test do
  gem "rake"
  gem "rb-readline"
  gem "aruba",     ">= 0.11", "< 3.0"
  gem "countloc",  "~> 0.4"
  gem "cucumber",  ">= 9.2", "< 11"
  gem "fakefs",    "~> 3.0"
  gem "maruku",    "~> 0.6"
  gem "minitest",  "~> 5.3", "< 6.0"
  gem "mocha",     "~> 2.0"
end

group :integration do
  gem "chef-cli"
  gem "kitchen-dokken"
  gem "kitchen-inspec"
  gem "kitchen-vagrant"
  # gem "inspec", "~> 5.22" # Fix dependency conflicts for ruby < 3.4
  # gem "train", "~> 3.10" # Fix dependency conflicts for ruby < 3.4
end

group :linting do
  gem "cookstyle", "~> 8.2"
end

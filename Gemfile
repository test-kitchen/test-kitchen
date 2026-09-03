source "https://rubygems.org"

gemspec

group :test do
  gem "rake"
  gem "rb-readline"
  gem "aruba",     ">= 0.11", "< 3.0"
  gem "countloc",  "~> 0.4"
  gem "cucumber",  ">= 9.2", "< 12"
  gem "fakefs",    "~> 3.0"
  gem "maruku",    "~> 0.7"
  gem "minitest",  "~> 6.0", "< 6.1"
  gem "mocha",     "~> 3.0"
  gem "simplecov", "~> 0.22", require: false
  gem "yard",      "~> 0.9"
end

# Acceptance-suite gems live in Gemfile.integration.

group :linting do
  gem "cookstyle", "~> 9.0"
end

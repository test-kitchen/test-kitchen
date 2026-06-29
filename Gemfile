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
end

group :integration do
  gem "cinc-auditor-bin", source: "https://rubygems.cinc.sh"
  gem "kitchen-cinc"
  gem "kitchen-cinc-auditor",
    git: "https://github.com/test-kitchen/kitchen-cinc-auditor.git",
    ref: "3d0b89eaa13f12da08a8761970e39c0f564c24c6"
  gem "kitchen-dokken"
  gem "kitchen-vagrant"
end

group :linting do
  gem "cookstyle", "~> 8.2"
end

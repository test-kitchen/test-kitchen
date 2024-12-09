source "https://rubygems.org"

gemspec

group :test do
  gem "rake"
  gem "rb-readline"
  gem "aruba",     ">= 0.11", "< 3.0"
  gem "countloc",  "~> 0.4"
  gem "cucumber",  ">= 9.2", "< 10"
  gem "fakefs",    "~> 2.0"
  gem "maruku",    "~> 0.6"
  gem "minitest",  "~> 5.3", "< 6.0"
  gem "mocha",     "~> 2.0"
end

group :integration do
  gem "chef-cli"
  gem "kitchen-dokken"
  gem "kitchen-inspec"
  gem "kitchen-vagrant"
end

group :linting do
  gem "cookstyle", "7.32.8"
end

# Platform specific gems
platforms :ruby do
  if RUBY_PLATFORM.include?('arm64-darwin')
    gem "bcrypt_pbkdf", "~> 1.1.0"
    gem "ed25519", "~> 1.3.0"
    gem "ffi", "~> 1.15.0"
  end
end

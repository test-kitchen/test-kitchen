source "https://rubygems.org"

# Specify your gem"s dependencies in test-kitchen.gemspec
gemspec

group :integration do
  gem "berkshelf"
  gem "kitchen-inspec"
  gem "kitchen-dokken"
  gem "kitchen-vagrant"
end

group :debug do
  gem "pry"
  gem "pry-byebug"
  gem "pry-stack_explorer"
end

group :chefstyle do
  gem "chefstyle", "1.6.1"
end
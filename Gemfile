source "https://rubygems.org"

# Specify your gem"s dependencies in test-kitchen.gemspec
gemspec

group :integration do
  gem "berkshelf"
  gem "kitchen-inspec"
  gem "kitchen-dokken"
  gem "kitchen-vagrant"
  gem "chef-config"
end

group :debug do
  gem "pry", "~>0.12"
  gem "pry-byebug"
  gem "pry-stack_explorer"
end

group :chefstyle do
  gem "chefstyle", "2.2.1"
end
# -*- encoding: utf-8 -*-
source "https://rubygems.org"
gemspec

gem "train", "~> 0.22"

group :integration do
  gem "berkshelf"
  gem "kitchen-inspec"
  gem "kitchen-dokken"
  gem "kitchen-vagrant"
end

group :changelog do
  gem "github_changelog_generator", "1.11.3"
end

group :debug do
  gem "pry"
  gem "pry-byebug"
  gem "pry-stack_explorer"
end

group :chefstyle do
  gem "chefstyle"
end

group :docs do
  gem "yard"
end

instance_eval(ENV["GEMFILE_MOD"]) if ENV["GEMFILE_MOD"]

# If you want to load debugging tools into the bundle exec sandbox,
# add these additional dependencies into chef/Gemfile.local
eval(IO.read(__FILE__ + ".local"), binding) if File.exist?(__FILE__ + ".local")

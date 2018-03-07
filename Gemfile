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

# To avoid bringing in development or test dependencies that are not
# absolutely needed, if you want to load tools not present in the gemspec
# or this Gemfile, add those additional dependencies into a Gemfile.local
# file which is ignored by this repository.
# rubocop:disable Security/Eval
eval(IO.read(__FILE__ + ".local"), binding) if File.exist?(__FILE__ + ".local")
# rubocop:enable Security/Eval

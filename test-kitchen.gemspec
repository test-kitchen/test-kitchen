# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kitchen/version"
require "English"

Gem::Specification.new do |gem|
  gem.name          = "test-kitchen"
  gem.version       = Kitchen::VERSION
  gem.license       = "Apache 2.0"
  gem.authors       = ["Fletcher Nichol"]
  gem.email         = ["fnichol@nichol.ca"]
  gem.description   = "Test Kitchen is an integration tool for developing " \
                      "and testing infrastructure code and software on " \
                      "isolated target platforms."
  gem.summary       = gem.description
  gem.homepage      = "http://kitchen.ci"

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = %w[kitchen]
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 1.9.1"

  gem.add_dependency "mixlib-shellout", ">= 1.2", "< 3.0"
  gem.add_dependency "net-scp",         "~> 1.1"
  gem.add_dependency "net-ssh",         ">= 2.9", "< 4.0"
  gem.add_dependency "net-ssh-gateway", "~> 1.2.0"
  gem.add_dependency "safe_yaml",       "~> 1.0"
  gem.add_dependency "thor",            "~> 0.18"
  gem.add_dependency "mixlib-install",  ">= 1.2", "< 3.0"

  gem.add_development_dependency "pry"
  gem.add_development_dependency "pry-byebug"
  gem.add_development_dependency "pry-stack_explorer"
  gem.add_development_dependency "rb-readline"
  gem.add_development_dependency "overcommit", "= 0.33.0"
  gem.add_development_dependency "winrm", "~> 2.0"
  gem.add_development_dependency "winrm-elevated", "~> 1.0"
  gem.add_development_dependency "winrm-fs", "~> 1.0"

  gem.add_development_dependency "bundler",   "~> 1.3"
  gem.add_development_dependency "rake", "~> 10.0"
  gem.add_development_dependency "github_changelog_generator", "1.11.3"

  gem.add_development_dependency "aruba",     "~> 0.11"
  gem.add_development_dependency "fakefs",    "~> 0.4"
  gem.add_development_dependency "minitest",  "~> 5.3"
  gem.add_development_dependency "mocha",     "~> 1.1"

  gem.add_development_dependency "cucumber",  "~> 2.1"

  gem.add_development_dependency "countloc",  "~> 0.4"
  gem.add_development_dependency "maruku",    "~> 0.6"
  gem.add_development_dependency "simplecov", "~> 0.7"
  gem.add_development_dependency "yard",      "~> 0.8"

  # style and complexity libraries are tightly version pinned as newer releases
  # may introduce new and undesireable style choices which would be immediately
  # enforced in CI
  gem.add_development_dependency "finstyle",  "1.5.0"
end

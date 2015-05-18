# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kitchen/driver/ec2_version.rb"

Gem::Specification.new do |gem|
  gem.name          = "kitchen-ec2"
  gem.version       = Kitchen::Driver::EC2_VERSION
  gem.license       = "Apache 2.0"
  gem.authors       = ["Fletcher Nichol"]
  gem.email         = ["fnichol@nichol.ca"]
  gem.description   = "A Test Kitchen Driver for Amazon EC2"
  gem.summary       = gem.description
  gem.homepage      = "http://kitchen.ci/"

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = []
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "test-kitchen", "~> 1.4"
  gem.add_dependency "excon"
  gem.add_dependency "multi_json"
  gem.add_dependency "aws-sdk-v1", "~> 1.59.0"
  gem.add_dependency "aws-sdk", "~> 2"

  gem.add_development_dependency "rspec",     "~> 3.2"
  gem.add_development_dependency "countloc",  "~> 0.4"
  gem.add_development_dependency "maruku",    "~> 0.6"
  gem.add_development_dependency "simplecov", "~> 0.7"
  gem.add_development_dependency "yard",      "~> 0.8"

  # style and complexity libraries are tightly version pinned as newer releases
  # may introduce new and undesireable style choices which would be immediately
  # enforced in CI
  gem.add_development_dependency "finstyle",  "1.4.0"
  gem.add_development_dependency "cane",      "2.6.2"
  gem.add_development_dependency "climate_control"
end

# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jamie/version'

Gem::Specification.new do |gem|
  gem.name          = "jamie"
  gem.version       = Jamie::VERSION
  gem.license       = 'Apache 2.0'
  gem.authors       = ["Fletcher Nichol"]
  gem.email         = ["fnichol@nichol.ca"]
  gem.description   = %q{A Chef convergence integration test harness}
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/jamie-ci/jamie"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = %w(jamie)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 1.9.1"

  gem.add_dependency 'thor'
  gem.add_dependency 'net-ssh'
  gem.add_dependency 'net-scp'
  gem.add_dependency 'mixlib-shellout'

  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'fakefs'
  gem.add_development_dependency 'guard-minitest'

  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'maruku'
  gem.add_development_dependency 'cane'
  gem.add_development_dependency 'tailor'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'countloc'
end

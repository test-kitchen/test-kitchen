# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jamie/version'

Gem::Specification.new do |gem|
  gem.name          = "jamie"
  gem.version       = Jamie::VERSION
  gem.authors       = ["Fletcher Nichol"]
  gem.email         = ["fnichol@nichol.ca"]
  gem.description   = %q{A Chef convergence integration test harness}
  gem.summary       = gem.description
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'hashie'
  gem.add_dependency 'mixlib-shellout'
  gem.add_dependency 'vagrant', '~> 1.0.5'

  gem.add_development_dependency 'cane'
  gem.add_development_dependency 'tailor'
end

# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jamie/driver/ec2_version.rb'

Gem::Specification.new do |gem|
  gem.name          = "jamie-ec2"
  gem.version       = Jamie::Driver::EC2_VERSION
  gem.authors       = ["Fletcher Nichol"]
  gem.email         = ["fnichol@nichol.ca"]
  gem.description   = "Jamie::Driver::Ec2 - A Jamie Driver for Ec2"
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/jamie-ci/jamie-ec2/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = []
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'jamie'
  gem.add_dependency 'fog'

  gem.add_development_dependency 'cane'
  gem.add_development_dependency 'tailor'
end

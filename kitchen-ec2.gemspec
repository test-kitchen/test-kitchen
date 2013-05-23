# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/ec2_version.rb'

Gem::Specification.new do |gem|
  gem.name          = "kitchen-ec2"
  gem.version       = Kitchen::Driver::EC2_VERSION
  gem.authors       = ["Fletcher Nichol"]
  gem.email         = ["fnichol@nichol.ca"]
  gem.description   = "Kitchen::Driver::Ec2 - A Test Kitchen Driver for Ec2"
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/opscode/kitchen-ec2/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = []
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'test-kitchen', '~> 1.0.0.alpha.7'
  gem.add_dependency 'fog'

  gem.add_development_dependency 'cane'
  gem.add_development_dependency 'tailor'
  gem.add_development_dependency 'countloc'
end

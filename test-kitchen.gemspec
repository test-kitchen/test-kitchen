# -*- encoding: utf-8 -*-
require File.expand_path('../lib/test-kitchen/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = "test-kitchen"
  s.version       = TestKitchen::VERSION
  s.summary       = 'Easily provision test environments for integration testing with Chef.'
  s.description   = s.summary
  s.authors       = ['Seth Chisamore']
  s.email         = ['schisamo@opscode.com']
  s.license       = 'Apache'
  s.homepage      = 'https://github.com/opscode/test-kitchen'
  s.files         = Dir['LICENSE', 'bin/kitchen', 'config/*', 'cookbooks/**/*', 'lib/**/*']
  s.executables   = 'kitchen'
  s.require_paths = ['lib']
  s.add_dependency('foodcritic', '~> 1.4.0')
  s.add_dependency('hashr', '~> 0.0.20')
  s.add_dependency('mixlib-cli', '~> 1.2.2')
  s.add_dependency('highline', '>= 1.6.9')
  s.add_dependency('vagrant', '~> 1.0.2')
  s.add_dependency('yajl-ruby', '~> 1.1.0')
  s.add_dependency('librarian', '~> 0.0.20')
end

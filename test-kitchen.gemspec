# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/version'

Gem::Specification.new do |gem|
  gem.name          = "test-kitchen"
  gem.version       = Kitchen::VERSION
  gem.license       = 'Apache 2.0'
  gem.authors       = ['Fletcher Nichol']
  gem.email         = ['fnichol@nichol.ca']
  gem.description   = %q{Test Kitchen is an integration tool for developing and testing infrastructure code and software on isolated target platforms.}
  gem.summary       = gem.description
  gem.homepage      = 'http://kitchen.ci'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = %w(kitchen)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 1.9.1'

  gem.add_dependency 'mixlib-shellout', '~> 1.2'
  gem.add_dependency 'net-scp',         '~> 1.1'
  gem.add_dependency 'net-ssh',         '~> 2.7'
  gem.add_dependency 'safe_yaml',       '~> 1.0'
  gem.add_dependency 'thor',            '~> 0.18'
  gem.add_dependency 'socksify',        '~> 1.5'

  gem.add_development_dependency 'bundler',   '~> 1.3'
  gem.add_development_dependency 'rake'

  gem.add_development_dependency 'aruba',     '~> 0.5'
  gem.add_development_dependency 'fakefs',    '~> 0.4'
  gem.add_development_dependency 'minitest',  '~> 5.1.0'
  gem.add_development_dependency 'mocha',     '~> 0.14'

  gem.add_development_dependency 'cane',      '~> 2.6'
  gem.add_development_dependency 'countloc',  '~> 0.4'
  gem.add_development_dependency 'maruku',    '~> 0.6'
  gem.add_development_dependency 'simplecov', '~> 0.7'
  gem.add_development_dependency 'tailor',    '~> 1.2'
  gem.add_development_dependency 'yard',      '~> 0.8'
end

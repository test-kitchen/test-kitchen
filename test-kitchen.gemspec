lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kitchen/version"
require "English"

Gem::Specification.new do |gem|
  gem.name          = "test-kitchen"
  gem.version       = Kitchen::VERSION
  gem.license       = "Apache-2.0"
  gem.authors       = ["Fletcher Nichol"]
  gem.email         = ["fnichol@nichol.ca"]
  gem.description   = "Test Kitchen is an integration tool for developing " \
                      "and testing infrastructure code and software on " \
                      "isolated target platforms."
  gem.summary       = gem.description
  gem.homepage      = "https://kitchen.ci/"

  # The gemfile and gemspec are necessary for appbundler in ChefDK / Workstation
  gem.files         = %w{LICENSE test-kitchen.gemspec Gemfile Rakefile} + Dir.glob("{bin,lib,templates,support}/**/*")
  gem.executables   = %w{kitchen}
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.1"

  gem.add_dependency "bcrypt_pbkdf",       "~> 1.0" # ed25519 ssh key support
  gem.add_dependency "chef-utils",         ">= 16.4.35"
  gem.add_dependency "ed25519",            "~> 1.2" # ed25519 ssh key support
  gem.add_dependency "mixlib-install",     "~> 3.6"
  gem.add_dependency "mixlib-shellout",    ">= 1.2", "< 4.0"
  gem.add_dependency "net-scp",            ">= 1.1", "< 5.0" # pinning until we can confirm 4+ works
  gem.add_dependency "net-ssh",            ">= 2.9", "< 8.0" # pinning until we can confirm 8+ works
  gem.add_dependency "net-ssh-gateway",    ">= 1.2", "< 3.0" # pinning until we can confirm 3+ works
  gem.add_dependency "thor",               ">= 0.19", "< 2.0"
  gem.add_dependency "winrm",              "~> 2.0"
  gem.add_dependency "winrm-elevated",     "~> 1.0"
  gem.add_dependency "winrm-fs",           "~> 1.1"
  # Required to run the Chef provisioner local license check for remote systems
  # TK is not under Chef EULA
  gem.add_dependency "license-acceptance", ">= 1.0.11", "< 3.0" # pinning until we can confirm 3+ works
end

# frozen_string_literal: true

require 'kitchen/cli'
require 'kitchen/errors'
require_relative 'kitchen/provisioner/dokken_ci'

Kitchen.with_friendly_errors do
  Kitchen::CLI.start(['verify', *ARGV])
end

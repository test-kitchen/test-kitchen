# -*- encoding: utf-8 -*-

# Set up the environment for testing
require "aruba/cucumber"
require "aruba/in_process"
require "aruba/spawn_process"
require "kitchen"
require "kitchen/cli"

class ArubaHelper

  def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
    @argv = argv
    @stdin = stdin
    @stdout = stdout
    @stderr = stderr
    @kernel = kernel
  end

  def execute!
    $stdout = @stdout
    $stdin = @stdin

    kitchen_cli = Kitchen::CLI
    kitchen_cli.start(@argv)
    @kernel.exit(0)
  end
end

Aruba.configure do |config|
  # We need a long timeout for `kitchen discover`
  config.exit_timeout    = 120
  config.io_wait_timeout = 2
end

Before do
  @cleanup_dirs = []

  Aruba::Processes::InProcess.main_class = ArubaHelper
end

After do |s|
  # Tell Cucumber to quit after this scenario is done - if it failed.
  # This is useful to inspect the 'tmp/aruba' directory before any other
  # steps are executed and clear it out.
  Cucumber.wants_to_quit = true if s.failed?

  # Restore environment variables to their original settings, if they have
  # been saved off
  ENV.keys.select { |key| key =~ /^_CUKE_/ }.each do |backup_key|
    ENV[backup_key.sub(/^_CUKE_/, "")] = ENV.delete(backup_key)
  end

  @cleanup_dirs.each { |dir| FileUtils.rm_rf(dir) }
end

def backup_envvar(key)
  ENV["_CUKE_#{key}"] = ENV[key]
end

def restore_envvar(key)
  ENV[key] = ENV.delete("_CUKE_#{key}")
end

def unbundlerize
  keys = %w[BUNDLER_EDITOR BUNDLE_BIN_PATH BUNDLE_GEMFILE RUBYOPT]

  keys.each { |key| backup_envvar(key); ENV.delete(key) }
  yield
  keys.each { |key| restore_envvar(key) }
end

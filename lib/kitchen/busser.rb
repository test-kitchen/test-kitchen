# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, 2013, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "base64"
require "digest"
require "kitchen"

module Kitchen

  # Command string generator to interface with Busser. The commands that are
  # generated are safe to pass to an SSH command or as an unix command
  # argument (escaped in single quotes).
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Busser

    include Configurable
    include Logging

    default_config :kitchen_root, Dir.pwd
    default_config :root_path, "/tmp/busser"
    default_config :version, "busser"

    default_config :test_base_path do |busser|
      Kitchen::DEFAULT_TEST_DIR
    end

    default_config :ruby_bindir do |busser|
      busser.instance.transport.shell.default_ruby_bin
    end

    default_config :busser_bin do |busser|
      File.join(busser[:root_path], "gems/bin/busser")
    end

    # Constructs a new Busser command generator, given a suite name.
    #
    # @param [String] suite_name name of suite on which to operate
    #   (**Required**)
    # @param [Hash] opts optional configuration
    # @option opts [String] :kitchen_root local path to the root of the project
    # @option opts [String] :instance_ruby_bindir path to the directory
    #   containing the Ruby binary on the remote instance
    def initialize(suite_name, opts = {})
      validate_options(suite_name)
      init_config(opts)
      config[:suite_name] = suite_name
    end

    # Returns the name of this busser, suitable for display in a CLI.
    #
    # @return [String] name of this busser
    def name
      config[:suite_name]
    end

    # Returns an array of all files to be copied to the instance
    #
    # @return [Array<String>] array of local payload files
    def local_payload
      local_suite_files.concat(helper_files)
    end

    # Returns a command string which installs Busser, and installs all
    # required Busser plugins for the suite.
    #
    # If no work needs to be performed, for example if there are no tests for
    # the given suite, then `nil` will be returned.
    #
    # @return [String] a command string to setup the test suite, or nil if no
    #   work needs to be performed
    def setup_cmd
      return if local_suite_files.empty?
      cmd = "#{busser_setup_env}\n"
      cmd << shell.busser_setup(config[:ruby_bindir], config[:root_path], gem_install_args)
      cmd << "\n#{shell.sudo(config[:busser_bin])} plugin install #{plugins.join(" ")}"
      shell.wrap_command(cmd)
    end

    # Returns a command string which removes all suite test files on the
    # instance.
    #
    # If no work needs to be performed, for example if there are no tests for
    # the given suite, then `nil` will be returned.
    #
    # @return [String] a command string to remove all suite test files, or
    #   nil if no work needs to be performed.
    def cleanup_cmd
      return if local_suite_files.empty?

      cmd = <<-CMD.gsub(/^ {8}/, "")
        #{busser_setup_env}

        #{shell.sudo(config[:busser_bin])} suite cleanup

      CMD
      shell.wrap_command(cmd)
    end

    # Returns a command string which runs all Busser suite tests for the suite.
    #
    # If no work needs to be performed, for example if there are no tests for
    # the given suite, then `nil` will be returned.
    #
    # @return [String] a command string to run the test suites, or nil if no
    #   work needs to be performed
    def run_cmd
      return if local_suite_files.empty?

      cmd = <<-CMD.gsub(/^ {8}/, "")
        #{busser_setup_env}

        #{shell.sudo(config[:busser_bin])} test
      CMD

      shell.wrap_command(cmd)
    end

    # Performs any final configuration required to do its work.
    # A reference to an Instance is required as configuration dependant
    # data may need access through an Instance. This also acts as a hook
    # point where the object may wish to perform other last minute checks,
    # valiations, or configuration expansions.
    #
    # @param instance [Instance] an associated instance
    # @return [self] itself, used for chaining
    # @raise [ClientError] if instance parameter is nil
    def finalize_config!(instance)
      super
      load_needed_dependencies!
      config[:test_base_path] = File.expand_path(config[:test_base_path], config[:kitchen_root])
      self
    end

    private

    # Loads any needed dependencies
    #
    # @raise [ClientError] if any library loading fails or any of the
    #   dependency requirements cannot be satisfied
    # @api private
    def load_needed_dependencies!
    end

    # Ensures that the object is internally consistent and otherwise raising
    # an exception.
    #
    # @param suite_name [String] the suite name
    # @raise [ClientError] if a suite name is missing
    # @raise [UserError] if the suite name is invalid
    # @api private
    def validate_options(suite_name)
      if suite_name.nil?
        raise ClientError, "Busser#new requires a suite_name"
      end

      if suite_name == "helper"
        raise UserError,
          "Suite name invalid: 'helper' is a reserved directory name."
      end
    end

    # Returns a uniquely sorted Array of Busser plugin gems that need to
    # be installed for the related suite.
    #
    # @return [Array<String>] a lexically sorted, unique item array of Busser
    #   plugin gem names
    # @api private
    def plugins
      non_suite_dirs = %w[data data_bags environments nodes roles]
      glob = File.join(config[:test_base_path], config[:suite_name], "*")
      Dir.glob(glob).reject { |d|
        !File.directory?(d) || non_suite_dirs.include?(File.basename(d))
      }.map { |d| "busser-#{File.basename(d)}" }.sort.uniq
    end

    # Returns an Array of test suite filenames for the related suite currently
    # residing on the local workstation. Any special provisioner-specific
    # directories (such as a Chef roles/ directory) are excluded.
    #
    # @return [Array<String>] array of suite files
    # @api private
    def local_suite_files
      base = File.join(config[:test_base_path], config[:suite_name])
      glob = File.join(base, "*/**/*")
      Dir.glob(glob).reject do |f|
        chef_data_dir?(base, f) || File.directory?(f)
      end
    end

    # Determines whether or not a local workstation file exists under a
    # Chef-related directory.
    #
    # @return [truthy,falsey] whether or not a given file is some kind of
    #   Chef-related file
    # @api private
    def chef_data_dir?(base, file)
      file =~ %r{^#{base}/(data|data_bags|environments|nodes|roles)/}
    end

    # Returns an Array of common helper filenames currently residing on the
    # local workstation.
    #
    # @return [Array<String>] array of helper files
    # @api private
    def helper_files
      glob = File.join(config[:test_base_path], "helpers", "*/**/*")
      Dir.glob(glob).reject { |f| File.directory?(f) }
    end

    # @return [Transport.shell] the transport desired shell for this instance
    # This would help us know which commands to use. Bourne, Powershell, etc.
    #
    # @api private
    def shell
      instance.transport.shell
    end

    # Returns a command string that sets appropriate environment variables for
    # busser commands.
    #
    # @return [String] command string
    # @api private
    def busser_setup_env
      env = []

      env << shell.set_env("BUSSER_ROOT", "#{config[:root_path]}")
      env << shell.set_env("GEM_HOME", "#{config[:root_path]}/gems")
      env << shell.set_env("GEM_PATH", "#{config[:root_path]}/gems")
      env << shell.set_env("GEM_CACHE", "#{config[:root_path]}/gems/cache")

      env.join("\n")
    end

    # Returns arguments to a `gem install` command, suitable to install the
    # Busser gem.
    #
    # @return [String] arguments string
    # @api private
    def gem_install_args
      gem, version = config[:version].split("@")
      gem, version = "busser", gem if gem =~ /^\d+\.\d+\.\d+/

      args = gem
      args += " --version #{version}" if version
      args += " --no-rdoc --no-ri"
      args
    end
  end
end

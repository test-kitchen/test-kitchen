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

require "kitchen/verifier/base"

module Kitchen

  module Verifier

    # Command string generator to interface with Busser. The commands that are
    # generated are safe to pass to an SSH command or as an unix command
    # argument (escaped in single quotes).
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Busser < Kitchen::Verifier::Base

      kitchen_verifier_api_version 1

      plugin_version Kitchen::VERSION

      default_config :busser_bin do |verifier|
        verifier.
          remote_path_join(%W[#{verifier[:root_path]} bin busser]).
          tap { |path| path.concat(".bat") if verifier.windows_os? }
      end

      default_config :ruby_bindir do |verifier|
        if verifier.windows_os?
          "$env:systemdrive\\opscode\\chef\\embedded\\bin"
        else
          verifier.remote_path_join(%W[#{verifier[:chef_omnibus_root]} embedded bin])
        end
      end

      default_config :version, "busser"

      expand_path_for :test_base_path

      # Creates a new Busser object using the provided configuration data
      # which will be merged with any default configuration.
      #
      # @param config [Hash] provided driver configuration
      def initialize(config = {})
        init_config(config)
      end

      # (see Base#create_sandbox)
      def create_sandbox
        super
        prepare_helpers
        prepare_suites
      end

      # (see Base#init_command)
      def init_command
        return if local_suite_files.empty?

        cmd = sudo(config[:busser_bin]).dup.
          tap { |str| str.insert(0, "& ") if powershell_shell? }

        prefix_command(wrap_shell_code(Util.outdent!(<<-CMD)))
          #{busser_env}

          #{cmd} suite cleanup
        CMD
      end

      # (see Base#install_command)
      def install_command
        return if local_suite_files.empty?

        vars = install_command_vars

        prefix_command(shell_code_from_file(vars, "busser_install_command"))
      end

      # (see Base#run_command)
      def run_command
        return if local_suite_files.empty?

        cmd = sudo(config[:busser_bin]).dup.
          tap { |str| str.insert(0, "& ") if powershell_shell? }

        prefix_command(wrap_shell_code(Util.outdent!(<<-CMD)))
          #{busser_env}

          #{cmd} test
        CMD
      end

      # Legacy method stub for `#setup_cmd` which calls `#install_command`.
      #
      # @return [String] command string
      # @deprecated When backwards compatibility for old Busser methods is
      #   removed, this method will no longer be available. Use
      #   `#install_command` in its place.
      define_method(:setup_cmd) { install_command }

      # Legacy method stub for `#run_cmd` which calls `#run_command`.
      #
      # @return [String] command string
      # @deprecated When backwards compatibility for old Busser methods is
      #   removed, this method will no longer be available. Use
      #   `#run_command` in its place.
      define_method(:run_cmd) { run_command }

      # Legacy method stub for `#sync_cmd`.
      #
      # @deprecated When backwards compatibility for old Busser methods is
      #   removed, this method will no longer be available. Use
      #   `transport#upload` to transfer test files in its place.
      def sync_cmd
        warn("Legacy call to #sync_cmd cannot be preserved, meaning that " \
          "test files will not be uploaded. " \
          "Code that calls #sync_cmd can now use the transport#upload " \
          "method to transfer files.")
      end

      private

      # Returns a command string that sets appropriate environment variables for
      # busser commands.
      #
      # @return [String] command string
      # @api private
      def busser_env
        root = config[:root_path]
        gem_home = gem_path = remote_path_join(root, "gems")
        gem_cache = remote_path_join(gem_home, "cache")

        [
          shell_env_var("BUSSER_ROOT", root),
          shell_env_var("GEM_HOME", gem_home),
          shell_env_var("GEM_PATH", gem_path),
          shell_env_var("GEM_CACHE", gem_cache)
        ].join("\n").
          tap { |str| str.insert(0, reload_ps1_path) if windows_os? }
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

      # Returns arguments to a `gem install` command, suitable to install the
      # Busser gem.
      #
      # @return [String] arguments string
      # @api private
      def gem_install_args
        gem, version = config[:version].split("@")
        gem, version = "busser", gem if gem =~ /^\d+\.\d+\.\d+/

        root = config[:root_path]
        gem_bin = remote_path_join(root, "bin")

        # We don't want the gems to be installed in the home directory,
        # this will force the bindir and the gem install location both
        # to be under /tmp/verifier
        args = gem
        args += " --version #{version}" if version
        args += " --no-rdoc --no-ri --no-format-executable -n #{gem_bin}"
        args += " --no-user-install"
        args
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

      def install_command_vars
        ruby = remote_path_join(config[:ruby_bindir], "ruby").
          tap { |path| path.concat(".exe") if windows_os? }
        gem = remote_path_join(config[:ruby_bindir], "gem")

        [
          busser_env,
          shell_var("ruby", ruby),
          shell_var("gem", gem),
          shell_var("version", config[:version]),
          shell_var("gem_install_args", gem_install_args),
          shell_var("busser", sudo(config[:busser_bin])),
          shell_var("plugins", plugins.join(" "))
        ].join("\n")
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

      # Copies all common testing helper files into the suites directory in
      # the sandbox.
      #
      # @api private
      def prepare_helpers
        base = File.join(config[:test_base_path], "helpers")

        helper_files.each do |src|
          dest = File.join(sandbox_suites_dir, src.sub("#{base}/", ""))
          FileUtils.mkdir_p(File.dirname(dest))
          FileUtils.cp(src, dest, :preserve => true)
        end
      end

      # Copies all test suite files into the suites directory in the sandbox.
      #
      # @api private
      def prepare_suites
        base = File.join(config[:test_base_path], config[:suite_name])

        local_suite_files.each do |src|
          dest = File.join(sandbox_suites_dir, src.sub("#{base}/", ""))
          FileUtils.mkdir_p(File.dirname(dest))
          FileUtils.cp(src, dest, :preserve => true)
        end
      end

      # @return [String] path to suites directory under sandbox path
      # @api private
      def sandbox_suites_dir
        File.join(sandbox_path, "suites")
      end
    end
  end
end

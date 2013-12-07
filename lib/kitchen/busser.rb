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

require 'base64'
require 'digest'

module Kitchen

  # Command string generator to interface with Busser. The commands that are
  # generated are safe to pass to an SSH command or as an unix command
  # argument (escaped in single quotes).
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Busser

    # Constructs a new Busser command generator, given a suite name.
    #
    # @param [String] suite_name name of suite on which to operate
    #   (**Required**)
    # @param [Hash] opts optional configuration
    # @option opts [String] :kitchen_root local path to the root of the project
    # @option opts [String] :instance_ruby_bindir path to the directory
    #   containing the Ruby binary on the remote instance
    # @option opts [TrueClass, FalseClass] :sudo whether or not to invoke
    #   sudo before commands requiring root access (default: `true`)
    def initialize(suite_name, opts = {})
      validate_options(suite_name)

      kitchen_root = opts.fetch(:kitchen_root) { Dir.pwd }
      test_base_path = opts.fetch(:test_base_path, Kitchen::DEFAULT_TEST_DIR)

      @config = Hash.new
      @config[:kitchen_root] = kitchen_root
      @config[:test_base_path] = File.expand_path(test_base_path, kitchen_root)
      @config[:suite_name] = suite_name
      @config[:sudo] = opts.fetch(:sudo, true)
      @config[:ruby_bindir] = opts.fetch(:ruby_bindir, DEFAULT_RUBY_BINDIR)
      @config[:root_path] = opts.fetch(:root_path, DEFAULT_ROOT_PATH)
      @config[:version] = opts.fetch(:version, "busser")
      @config[:busser_bin] = opts.fetch(:busser_bin, File.join(@config[:root_path], "bin/busser"))
    end

    # Returns the name of this busser, suitable for display in a CLI.
    #
    # @return [String] name of this busser
    def name
      config[:suite_name]
    end

    # Returns an array of configuration keys.
    #
    # @return [Array] array of configuration keys
    def config_keys
      config.keys
    end

    # Provides hash-like access to configuration keys.
    #
    # @param attr [Object] configuration key
    # @return [Object] value at configuration key
    def [](attr)
      config[attr]
    end

    # Returns a Hash of configuration and other useful diagnostic information.
    #
    # @return [Hash] a diagnostic hash
    def diagnose
      result = Hash.new
      config_keys.sort.each { |k| result[k] = config[k] }
      result
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
      @setup_cmd ||= if local_suite_files.empty?
        nil
      else
        setup_cmd  = []
        setup_cmd << busser_setup_env
        setup_cmd << "if ! #{sudo}#{config[:ruby_bindir]}/gem list busser -i >/dev/null"
        setup_cmd << "then #{sudo}#{config[:ruby_bindir]}/gem install #{gem_install_args}"
        setup_cmd << "fi"
        setup_cmd << "gem_bindir=`#{config[:ruby_bindir]}/ruby -rrubygems -e \"puts Gem.bindir\"`"
        setup_cmd << "#{sudo}${gem_bindir}/busser setup"
        setup_cmd << "#{sudo}#{config[:busser_bin]} plugin install #{plugins.join(' ')}"

        # use Bourne (/bin/sh) as Bash does not exist on all Unix flavors
        "sh -c '#{setup_cmd.join('; ')}'"
      end
    end

    # Returns a command string which transfers all suite test files to the
    # instance.
    #
    # If no work needs to be performed, for example if there are no tests for
    # the given suite, then `nil` will be returned.
    #
    # @return [String] a command string to transfer all suite test files, or
    #   nil if no work needs to be performed.
    def sync_cmd
      @sync_cmd ||= if local_suite_files.empty?
        nil
      else
        sync_cmd  = []
        sync_cmd << busser_setup_env
        sync_cmd << "#{sudo}#{config[:busser_bin]} suite cleanup"
        sync_cmd << "#{local_suite_files.map { |f| stream_file(f, remote_file(f, config[:suite_name])) }.join("; ")}"
        sync_cmd << "#{helper_files.map { |f| stream_file(f, remote_file(f, "helpers")) }.join}"

        # use Bourne (/bin/sh) as Bash does not exist on all Unix flavors
        "sh -c '#{sync_cmd.join('; ')}'"
      end
    end

    # Returns a command string which runs all Busser suite tests for the suite.
    #
    # If no work needs to be performed, for example if there are no tests for
    # the given suite, then `nil` will be returned.
    #
    # @return [String] a command string to run the test suites, or nil if no
    #   work needs to be performed
    def run_cmd
      @run_cmd ||= if local_suite_files.empty?
        nil
      else
        run_cmd  = []
        run_cmd << busser_setup_env
        run_cmd << "#{sudo}#{config[:busser_bin]} test"

        # use Bourne (/bin/sh) as Bash does not exist on all Unix flavors
        "sh -c '#{run_cmd.join('; ')}'"
      end
    end

    private

    DEFAULT_RUBY_BINDIR = "/opt/chef/embedded/bin".freeze
    DEFAULT_ROOT_PATH = "/tmp/busser".freeze

    attr_reader :config

    def validate_options(suite_name)
      if suite_name.nil?
        raise ClientError, "Busser#new requires a suite_name"
      end

      if suite_name == 'helper'
        raise UserError,
          "Suite name invalid: 'helper' is a reserved directory name."
      end
    end

    def plugins
      glob = File.join(config[:test_base_path], config[:suite_name], "*")
      Dir.glob(glob).reject { |d|
        ! File.directory?(d) || non_suite_dirs.include?(File.basename(d))
      }.map { |d| "busser-#{File.basename(d)}" }.sort.uniq
    end

    def local_suite_files
      base = File.join(config[:test_base_path], config[:suite_name])
      glob = File.join(base, "*/**/*")
      Dir.glob(glob).reject do |f|
         is_chef_data_dir?(base, f) || File.directory?(f)
      end
    end

    def is_chef_data_dir?(base, file)
      file =~ %r[^#{base}/(data|data_bags|environments|nodes|roles)/]
    end

    def helper_files
      Dir.glob(File.join(config[:test_base_path], "helpers", "*/**/*"))
    end

    def remote_file(file, dir)
      local_prefix = File.join(config[:test_base_path], dir)
      "$(#{sudo}#{config[:busser_bin]} suite path)/".concat(file.sub(%r{^#{local_prefix}/}, ''))
    end

    def stream_file(local_path, remote_path)
      local_file = IO.read(local_path)
      md5 = Digest::MD5.hexdigest(local_file)
      perms = sprintf("%o", File.stat(local_path).mode)[2, 4]
      stream_cmd = [
        "#{sudo}#{config[:busser_bin]}",
        "deserialize",
        "--destination=#{remote_path}",
        "--md5sum=#{md5}",
        "--perms=#{perms}"
      ].join(" ")

      stream_file_cmd  = []
      stream_file_cmd << %{echo "Uploading #{remote_path} (mode=#{perms})"}
      stream_file_cmd << %{echo "#{Base64.encode64(local_file).gsub("\n", '')}" | #{sudo}#{stream_cmd}}
      stream_file_cmd.join('; ')
    end

    def sudo
      config[:sudo] ? "sudo -E " : ""
    end

    def non_suite_dirs
      %w{data data_bags environments nodes roles}
    end

    def busser_setup_env
      [
        %{BUSSER_ROOT="#{config[:root_path]}"},
        %{GEM_HOME="#{config[:root_path]}/gems"},
        %{GEM_PATH="#{config[:root_path]}/gems"},
        %{GEM_CACHE="#{config[:root_path]}/gems/cache"},
        %{; export BUSSER_ROOT GEM_HOME GEM_PATH GEM_CACHE}
      ].join(" ")
    end

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

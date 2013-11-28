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

      @test_base_path = File.expand_path(test_base_path, kitchen_root)
      @suite_name = suite_name
      @use_sudo = opts.fetch(:sudo, true)
      @ruby_bindir = opts.fetch(:instance_ruby_bindir, DEFAULT_RUBY_BINDIR)
      @root_path = opts.fetch(:root_path, DEFAULT_ROOT_PATH)
      @version_string = opts.fetch(:version, "busser")
      @busser_bin = File.join(@root_path, "bin/busser")
    end

    # Returns the name of this busser, suitable for display in a CLI.
    #
    # @return [String] name of this busser
    def name
      suite_name
    end

    # Returns an array of configuration keys.
    #
    # @return [Array] array of configuration keys
    def config_keys
      [:test_base_path, :ruby_bindir, :root_path, :version_string,
        :busser_bin, :sudo, :suite_name]
    end

    # Provides hash-like access to configuration keys.
    #
    # @param attr [Object] configuration key
    # @return [Object] value at configuration key
    def [](attr)
      config_keys.include?(attr) ? self.send(attr) : nil
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
        # use Bourne (/bin/sh) as Bash does not exist on all Unix flavors
        <<-INSTALL_CMD.gsub(/^ {10}/, '')
          sh -c '
          #{busser_setup_env}
          if ! #{sudo}#{ruby_bindir}/gem list busser -i >/dev/null; then
            #{sudo}#{ruby_bindir}/gem install #{gem_install_args}
          fi
          gem_bindir=`#{ruby_bindir}/ruby -rrubygems -e "puts Gem.bindir"`
          #{sudo}${gem_bindir}/busser setup
          #{sudo}#{busser_bin} plugin install #{plugins.join(' ')}'
        INSTALL_CMD
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
        # use Bourne (/bin/sh) as Bash does not exist on all Unix flavors
        <<-INSTALL_CMD.gsub(/^ {10}/, '')
          sh -c '
          #{sudo}#{busser_bin} suite cleanup
          #{local_suite_files.map { |f| stream_file(f, remote_file(f, suite_name)) }.join}
          #{helper_files.map { |f| stream_file(f, remote_file(f, "helpers")) }.join}'
        INSTALL_CMD
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
      @run_cmd ||= local_suite_files.empty? ? nil : "#{sudo}#{busser_bin} test"
    end

    private

    DEFAULT_RUBY_BINDIR = "/opt/chef/embedded/bin".freeze
    DEFAULT_ROOT_PATH = "/tmp/busser".freeze

    attr_reader :test_base_path
    attr_reader :ruby_bindir
    attr_reader :root_path
    attr_reader :version_string
    attr_reader :busser_bin
    attr_reader :use_sudo
    attr_reader :suite_name

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
      Dir.glob(File.join(test_base_path, suite_name, "*")).reject { |d|
        ! File.directory?(d) || non_suite_dirs.include?(File.basename(d))
      }.map { |d| "busser-#{File.basename(d)}" }.sort.uniq
    end

    def local_suite_files
      Dir.glob(File.join(test_base_path, suite_name, "*/**/*")).reject do |f|
        f[/(data|data_bags|environments|nodes|roles)/] || File.directory?(f)
      end
    end

    def helper_files
      Dir.glob(File.join(test_base_path, "helpers", "*/**/*"))
    end

    def remote_file(file, dir)
      local_prefix = File.join(test_base_path, dir)
      "$(#{sudo}#{busser_bin} suite path)/".concat(file.sub(%r{^#{local_prefix}/}, ''))
    end

    def stream_file(local_path, remote_path)
      local_file = IO.read(local_path)
      md5 = Digest::MD5.hexdigest(local_file)
      perms = sprintf("%o", File.stat(local_path).mode)[2, 4]
      stream_cmd = [
        "#{sudo}#{busser_bin}",
        "deserialize",
        "--destination=#{remote_path}",
        "--md5sum=#{md5}",
        "--perms=#{perms}"
      ].join(" ")

      <<-STREAMFILE.gsub(/^ {8}/, '')
        echo "Uploading #{remote_path} (mode=#{perms})"
        #{sudo}cat <<"__EOFSTREAM__" | #{sudo}#{stream_cmd}
        #{Base64.encode64(local_file)}
        __EOFSTREAM__
      STREAMFILE
    end

    def sudo
      use_sudo ? "sudo -E " : ""
    end

    def busser_gem
      "busser"
    end

    def non_suite_dirs
      %w{data data_bags environments nodes roles}
    end

    def busser_setup_env
      [
        %{BUSSER_ROOT="#{root_path}"},
        %{GEM_HOME="#{root_path}/gems"},
        %{GEM_PATH="#{root_path}/gems"},
        %{GEM_CACHE="#{root_path}/gems/cache"},
        %{; export BUSSER_ROOT GEM_HOME GEM_PATH GEM_CACHE;}
      ].join(" ")
    end

    def gem_install_args
      gem, version = version_string.split("@")
      gem, version = "busser", gem if gem =~ /^\d+\.\d+\.\d+/

      args = gem
      args += " --version #{version}" if version
      args += " --no-rdoc --no-ri"
      args
    end
  end
end

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

module Kitchen

  # Command string generator to interface with Busser. The commands that are
  # generated are safe to pass to an SSH command or as an unix command
  # argument (escaped in single quotes).
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Busser

    include Configurable
    include Logging

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
      return if local_suite_files.empty?
      ruby    = "#{config[:ruby_bindir]}/ruby"
      gem     = sudo("#{config[:ruby_bindir]}/gem")
      busser  = sudo(config[:busser_bin])

      case shell
      when "bourne"

        cmd = <<-CMD.gsub(/^ {10}/, "")
          #{busser_setup_env}
          gem_bindir=`#{ruby} -rrubygems -e "puts Gem.bindir"`

          if ! #{gem} list busser -i >/dev/null; then
            #{gem} install #{gem_install_args}
          fi
          #{sudo("${gem_bindir}")}/busser setup
          #{busser} plugin install #{plugins.join(" ")}
        CMD
      when "powershell"
        cmd = <<-CMD.gsub(/^ {10}/, "")
          #{busser_setup_env}
          if ((gem list busser -i) -eq \"false\") {
            gem install #{gem_install_args}
          }
          # We have to modify Busser::Setup to work with PowerShell
          # busser setup
          #{busser} plugin install #{plugins.join(" ")}
        CMD
      else
        raise "[#{self}] Unsupported shell: #{shell}"
      end
      Util.wrap_command(cmd, shell)
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
      return if local_suite_files.empty?

      cmd = <<-CMD.gsub(/^ {8}/, "")
        #{busser_setup_env}

        #{sudo(config[:busser_bin])} suite cleanup

      CMD

      local_suite_files.each do |f|
        cmd << stream_file(f, remote_file(f, config[:suite_name])).concat("\n")
      end
      helper_files.each do |f|
        cmd << stream_file(f, remote_file(f, "helpers")).concat("\n")
      end

      Util.wrap_command(cmd, shell)
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

        #{sudo(config[:busser_bin])} test
      CMD

      Util.wrap_command(cmd, shell)
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
      # Overwrite the sudo configuration comming from the Transport
      config[:sudo] = instance.transport.sudo
      # Smart way to do this?
      config[:busser_bin] = "busser" if shell.eql?("powershell")
      self
    end

    private

    DEFAULT_RUBY_BINDIR = "/opt/chef/embedded/bin".freeze
    DEFAULT_ROOT_PATH = "/tmp/busser".freeze

    # Loads any needed dependencies
    #
    # @raise [ClientError] if any library loading fails or any of the
    #   dependency requirements cannot be satisfied
    # @api private
    def load_needed_dependencies!
    end

    # @return [Hash] a configuration hash
    # @api private
    attr_reader :config

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

    # Returns a command string that will, once evaluated, result in the
    # fully qualified destination path of a file on an instance.
    #
    # @param file [String] absolute path to the local file
    # @param dir [String] suite directory or helper directory name
    # @return [String] command string
    # @api private
    def remote_file(file, dir)
      local_prefix = File.join(config[:test_base_path], dir)
      case shell
      when "bourne"
        "`#{sudo(config[:busser_bin])} suite path`/".
          concat(file.sub(%r{^#{local_prefix}/}, ""))
      when "powershell"
        "$env:BUSSER_SUITE_PATH/".
          concat(file.sub(%r{^#{local_prefix}/}, ""))
      else
        raise "[#{self}] Unsupported shell: #{shell}"
      end
    end

    # Returns a command string that will, once evaluated, result in the copying
    # of a local file to a remote instance.
    #
    # @param local_path [String] the path to a local source file for copying
    # @param remote_path [String] the destrination path on the remote instance
    # @return [String] command string
    # @api private
    def stream_file(local_path, remote_path)
      local_file = IO.read(local_path)
      encoded_file = Base64.encode64(local_file).gsub("\n", "")
      md5 = Digest::MD5.hexdigest(local_file)
      perms = format("%o", File.stat(local_path).mode)[2, 4]
      stream_cmd = [
        sudo(config[:busser_bin]),
        "deserialize",
        "--destination=#{remote_path}",
        "--md5sum=#{md5}",
        "--perms=#{perms}"
      ].join(" ")

      [
        %{echo "Uploading #{remote_path} (mode=#{perms})"},
        %{echo "#{encoded_file}" | #{stream_cmd}}
      ].join("\n").concat("\n")
    end

    # Conditionally prefixes a command with a sudo command.
    #
    # @param command [String] command to be prefixed
    # @return [String] the command, conditionaly prefixed with sudo
    # @api private
    def sudo(command)
      config[:sudo] ? "sudo -E #{command}" : command
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
      case shell
      when "bourne"
        [
          %{BUSSER_ROOT="#{config[:root_path]}"},
          %{GEM_HOME="#{config[:root_path]}/gems"},
          %{GEM_PATH="#{config[:root_path]}/gems"},
          %{GEM_CACHE="#{config[:root_path]}/gems/cache"},
          %{\nexport BUSSER_ROOT GEM_HOME GEM_PATH GEM_CACHE}
        ].join(" ")
      when "powershell"
        [
          %{$env:BUSSER_ROOT="#{config[:root_path]}";},
          %{$env:GEM_HOME="#{config[:root_path]}/gems";},
          %{$env:GEM_PATH="#{config[:root_path]}/gems";},
          %{$env:PATH="$env:PATH;$env:GEM_PATH/bin";},
          %{try { $env:BUSSER_SUITE_PATH=@(#{@config[:busser_bin]} suite path) }},
          %{catch { $env:BUSSER_SUITE_PATH="" };},
          %{$env:GEM_CACHE="#{config[:root_path]}/gems/cache"}
        ].join(" ")
      else
        raise "[#{self}] Unsupported shell: #{shell}"
      end
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

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

    default_config :busser_bin do |busser|
      File.join(busser[:root_path], %W[bin busser])
    end

    default_config :root_path, "/tmp/busser"

    default_config :ruby_bindir, "/opt/chef/embedded/bin"

    default_config :sudo, true

    default_config(:suite_name) { |busser| busser.instance.suite.name }

    default_config :version, "busser"

    expand_path_for :test_base_path

    # Creates a new Busser object using the provided configuration data
    # which will be merged with any default configuration.
    #
    # @param config [Hash] provided driver configuration
    def initialize(config = {})
      init_config(config)
    end

    # Returns the name of this busser, suitable for display in a CLI.
    #
    # @return [String] name of this busser
    def name
      config[:suite_name]
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

      cmd = <<-CMD.gsub(/^ {8}/, "")
        #{busser_setup_env}
        gem_bindir=`#{ruby} -rrubygems -e "puts Gem.bindir"`

        if ! #{gem} list busser -i >/dev/null; then
          #{gem} install #{gem_install_args}
        fi
        #{sudo("${gem_bindir}")}/busser setup
        #{busser} plugin install #{plugins.join(" ")}
      CMD
      Util.wrap_command(cmd)
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

      Util.wrap_command(cmd)
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

      Util.wrap_command(cmd)
    end

    private

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
      "`#{sudo(config[:busser_bin])} suite path`/".
        concat(file.sub(%r{^#{local_prefix}/}, ""))
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

    # Returns a command string that sets appropriate environment variables for
    # busser commands.
    #
    # @return [String] command string
    # @api private
    def busser_setup_env
      [
        %{BUSSER_ROOT="#{config[:root_path]}"},
        %{GEM_HOME="#{config[:root_path]}/gems"},
        %{GEM_PATH="#{config[:root_path]}/gems"},
        %{GEM_CACHE="#{config[:root_path]}/gems/cache"},
        %{\nexport BUSSER_ROOT GEM_HOME GEM_PATH GEM_CACHE}
      ].join(" ")
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

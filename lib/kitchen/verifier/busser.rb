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

      default_config :busser_bin do |busser|
        File.join(busser[:root_path], %W[bin busser])
      end

      default_config :ruby_bindir, "/opt/chef/embedded/bin"

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

        cmd = Util.outdent!(<<-CMD)
          #{busser_setup_env}

          #{sudo(config[:busser_bin])} suite cleanup
        CMD
        Util.wrap_command(cmd)
      end

      # (see Base#install_command)
      def install_command
        return if local_suite_files.empty?

        ruby    = "#{config[:ruby_bindir]}/ruby"
        gem     = "#{config[:ruby_bindir]}/gem"
        busser  = sudo(config[:busser_bin])

        cmd = Util.outdent!(<<-CMD)
          #{busser_setup_env}
          gem_bindir=`#{ruby} -rrubygems -e "puts Gem.bindir"`

          if ! #{gem} list busser -i >/dev/null; then
            #{gem} install #{gem_install_args}
          fi
          if [ ! -f "$BUSSER_ROOT/bin/busser" ]; then
            ${gem_bindir}/busser setup
          fi
          #{busser} plugin install #{plugins.join(" ")}
        CMD
        Util.wrap_command(cmd)
      end

      # (see Base#run_command)
      def run_command
        return if local_suite_files.empty?

        cmd = <<-CMD.gsub(/^ {8}/, "")
          #{busser_setup_env}

          #{sudo(config[:busser_bin])} test
        CMD

        Util.wrap_command(cmd)
      end

      private

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

        args = gem
        args += " --version #{version}" if version
        args += " --no-rdoc --no-ri"
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

# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

require "kitchen/provisioner/chef_base"

module Kitchen

  module Provisioner

    # Chef Zero provisioner.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class ChefZero < ChefBase

      default_config :client_rb, {}
      default_config :ruby_bindir, "/opt/chef/embedded/bin"
      default_config :json_attributes, true
      default_config :chef_zero_host, nil
      default_config :chef_zero_port, 8889
      default_config :chef_client_path do |provisioner|
        File.join(provisioner[:chef_omnibus_root], provisioner.shell.chef_client_file)
      end

      # (see Base#create_sandbox)
      def create_sandbox
        super
        prepare_chef_client_zero_rb
        prepare_validation_pem
        prepare_client_rb
      end

      # (see Base#prepare_command)
      def prepare_command
        return if modern?

        ruby_bin = Pathname.new(config[:ruby_bindir])

        # we are installing latest chef in order to get chef-zero and
        # Chef::ChefFS only. The version of Chef that gets run will be
        # the installed omnibus package. Yep, this is funky :)
        cmd = <<-PREPARE.gsub(/^ {10}/, "")
          #{chef_client_zero_env(:export)}
          if ! #{shell.sudo(ruby_bin.join("gem"))} list chef-zero -i >/dev/null; then
            echo ">>>>>> Attempting to use chef-zero with old version of Chef"
            echo "-----> Installing chef zero dependencies"
            #{shell.sudo(ruby_bin.join("gem"))} install chef --no-ri --no-rdoc --conservative
          fi
        PREPARE

        shell.wrap_command(cmd)
      end

      # (see Base#run_command)
      def run_command
        cmd = modern? ? local_mode_command : shim_command

        shell.wrap_command([cmd, *chef_client_args].join(" "))
      end

      private

      # Returns the command that will run chef client in local mode (a.k.a.
      # chef zero mode).
      #
      # @return [String] the command string
      # @api private
      def local_mode_command
        "#{shell.sudo(config[:chef_client_path])} --local-mode"
      end

      # Returns the command that will run a backwards compatible shim script
      # that approximates local mode in a modern chef-client run.
      #
      # @return [String] the command string
      # @api private
      def shim_command
        [
          chef_client_zero_env,
          shell.sudo("#{config[:ruby_bindir]}/ruby"),
          "#{config[:root_path]}/chef-client-zero.rb"
        ].join(" ")
      end

      # Returns an Array of command line arguments for the chef client.
      #
      # @return [Array<String>] an array of command line arguments
      # @api private
      def chef_client_args
        level = config[:log_level] == :info ? :auto : config[:log_level]
        args = [
          "--config #{config[:root_path]}/client.rb",
          "--log_level #{level}",
          "--force-formatter",
          "--no-color"
        ]
        add_argument(args, :chef_zero_host, "--chef-zero-host %config%")
        add_argument(args, :chef_zero_port, "--chef-zero-port %config%")
        add_argument(args, :json_attributes, "--json-attributes #{config[:root_path]}/dna.json")
        add_argument(args, :log_file, "--logfile %config%")

        args
      end

      def add_argument(line, config_key, arg)
        config_val = config[config_key]
        return unless config_val
        line << arg.gsub("%config%", config_val.to_s)
      end

      # Writes a chef-client local-mode shim script to the sandbox directory
      # only if the desired version of Chef is old enough. The version of Chef
      # is determined using the `config[:require_chef_omnibus]` value.
      #
      # @api private
      def prepare_chef_client_zero_rb
        return if modern?

        info("Preparing chef-client-zero.rb")
        debug("Using a vendored chef-client-zero.rb")

        source = File.join(File.dirname(__FILE__),
          %w[.. .. .. support chef-client-zero.rb])
        FileUtils.cp(source, File.join(sandbox_path, "chef-client-zero.rb"))
      end

      # Writes a fake (but valid) validation.pem into the sandbox directory.
      #
      # @api private
      def prepare_validation_pem
        info("Preparing validation.pem")
        debug("Using a dummy validation.pem")

        source = File.join(File.dirname(__FILE__),
          %w[.. .. .. support dummy-validation.pem])
        FileUtils.cp(source, File.join(sandbox_path, "validation.pem"))
      end

      # Writes a client.rb configuration file to the sandbox directory.
      #
      # @api private
      def prepare_client_rb
        data = default_config_rb.merge(config[:client_rb])

        info("Preparing client.rb")
        debug("Creating client.rb from #{data.inspect}")

        File.open(File.join(sandbox_path, "client.rb"), "wb") do |file|
          file.write(format_config_file(data))
        end
      end

      # Generates a string of shell environment variables needed for the
      # chef-client-zero.rb shim script to properly function.
      #
      # @param extra [Symbol] whether or not the environment variables need to
      #   be exported, using the `:export` symbol (default: `nil`)
      # @return [String] a shell script string
      # @api private
      def chef_client_zero_env(extra = nil)
        args = [
          %{CHEF_REPO_PATH="#{config[:root_path]}"},
          %{GEM_HOME="#{config[:root_path]}/chef-client-zero-gems"},
          %{GEM_PATH="#{config[:root_path]}/chef-client-zero-gems"},
          %{GEM_CACHE="#{config[:root_path]}/chef-client-zero-gems/cache"}
        ]
        if extra == :export
          args << %{; export CHEF_REPO_PATH GEM_HOME GEM_PATH GEM_CACHE;}
        end
        args.join(" ")
      end

      # Determines whether or not local mode (a.k.a chef zero mode) is
      # supported in the version of Chef as determined by inspecting the
      # require_chef_omnibus config variable.
      #
      # The only way this method returns false is if require_chef_omnibus has
      # an explicit version set to less than 11.8.0, when chef zero mode was
      # introduced. Otherwise a modern Chef installation is assumed.
      #
      # @return [true,false] whether or not the desired version of Chef
      #   supports local mode
      # @api private
      def modern?
        version = config[:require_chef_omnibus]

        case version
        when nil, false, true, "latest"
          true
        else
          Gem::Version.new(version) >= Gem::Version.new("11.8.0") ? true : false
        end
      end
    end
  end
end

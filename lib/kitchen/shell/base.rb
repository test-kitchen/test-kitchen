# -*- encoding: utf-8 -*-
#
# Author:: Matt Wrock (<matt@mattwrock.com>)
#
# Copyright (C) 2014, Matt Wrock
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

module Kitchen

  module Shell

    # Base class for a shell.
    #
    # @author Matt Wrock <matt@mattwrock.com>
    class Base

      include Configurable

      # Create a new Shell object using the provided configuration data
      # which will be merged with any default configuration.
      #
      # @param config [Hash] provided shell configuration
      def initialize(config = {})
        init_config(config)
      end

      # path to where ruby is installed
      #
      # @return [String] path to ruby
      def default_ruby_bin
        "/opt/chef/embedded/bin"
      end

      # Path to the busser command for calling busser functions
      #
      # @param busser_root [String] root path to busser installation
      # @return [String] path to busser command
      def default_busser_bin(busser_root)
        File.join(busser_root, "gems/bin/busser")
      end

      # Returns the name of this shell.
      #
      # @return [String] name of this shell
      def name
        self.class.name.split("::").last
      end

      # Command that installs and configures the busser
      #
      # @param busser_root [String] root path to busser installation
      # @param gem_install_args [String] arguments to pass to gem
      # command when installing busser gems
      # @return [String] command to run on test instance that
      # installs and sets up busser
      def busser_setup(busser_root, gem_install_args) # rubocop:disable Lint/UnusedMethodArgument
      end

      # Command for setting environment variables on the test instance
      #
      # @param key [String] environmnt variable name
      # @param value [String] value to be assigned to environment variable
      # @return [String] command for setting an environment variable on
      # the test instance
      def set_env(key, value) # rubocop:disable Lint/UnusedMethodArgument
      end

      # Command for adding a directory path to the current shell's path
      #
      # @param dir [String] directory to add to path
      # @return [String] command that adds the directory to the shell's path
      def add_to_path(dir) # rubocop:disable Lint/UnusedMethodArgument
      end

      # Returns a file containing a set of Shell compatible helper
      # functions. This function is usually called inline in a string that
      # will be executed remotely on a test instance.
      #
      # @return [String] file containing useful helper functions
      def helper_file
        ""
      end

      # Performs any final configuration required for the shell to do its
      # work. A reference to an Instance is required as configuration dependant
      # data may need access through an Instance. This also acts as a hook
      # point where the object may wish to perform other last minute checks,
      # valiations, or configuration expansions.
      #
      # @param instance [Instance] an associated instance
      # @return [self] itself, used for chaining
      # @raise [ClientError] if instance parameter is nil
      def finalize_config!(instance)
        super
        config[:sudo] = instance.transport.sudo
        self
      end

      # Generates a command (or series of commands) wrapped so that it can be
      # invoked on a remote instance or locally.
      #
      # @param [String] the command
      # @return [String] a wrapped command string
      def wrap_command(command)
        command
      end

      # Conditionally prefixes a command with a sudo command.
      #
      # @param command [String] command to be prefixed
      # @return [String] the command, conditionaly prefixed with sudo
      def sudo(script)
        script
      end
    end
  end
end

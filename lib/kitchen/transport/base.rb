# -*- encoding: utf-8 -*-
#
# Author:: Salim Afiune (<salim@afiunemaya.com.mx>)
#
# Copyright (C) 2014, Salim Afiune
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

require "kitchen/lazy_hash"

require "kitchen/errors"
require "kitchen/login_command"

module Kitchen

  module Transport

    # Wrapped exception for any internally raised Transport errors.
    #
    # @author Salim Afiune <salim@afiunemaya.com.mx>
    class TransportFailed < TransientFailure; end

    # Base class for a transport.
    #
    # @author Salim Afiune <salim@afiunemaya.com.mx>
    class Base

      include Configurable
      include Logging

      # Create a new Transport object using the provided configuration data
      # which will be merged with any default configuration.
      #
      # @param config [Hash] provided transport configuration
      def initialize(config = {})
        init_config(config)
      end

      # Configure Transport and allows the callee to use it.
      #
      # @example block usage
      #
      #   state = {
      #      :hostname => "remote.example.com",
      #      :username => "root"
      #   }
      #
      #   transport.connection(state) do |ssh|
      #     ssh.exec("sudo apt-get update")
      #     ssh.upload!("/tmp/data.txt", "/var/lib/data.txt")
      #   end
      #
      # @param state [Hash] configuration hash state
      # @yield [self] if a block is given then the constructed object yields
      #   itself and calls `#disconnect` at the end, closing the remote connection
      def connection(state)
        @options  =  build_transport_args(state)
        @hostname = state[:hostname] if state[:hostname] 
        @username = state[:username] if state[:username]
        @logger   = @options.delete(:logger) || ::Logger.new(STDOUT)

        if block_given?
          yield self
          disconnect
        end
      end

      # Returns the name of this transport, suitable for display in a CLI.
      #
      # @return [String] name of this transport
      def name
        self.class.name.split("::").last.downcase
      end

      # Execute a command on the remote host.
      #
      # @param command [String] command string to execute
      # @raise [TransportFailed] if the command does not exit with a 0 code
      def execute(command) # rubocop:disable Lint/UnusedMethodArgument
      end

      # Uploads a local path or file to remote host.
      #
      # @param local [String] path to local file
      # @param remote [String] path to remote file destination
      # @param options [Hash] configuration options that are passed.
      def upload!(local, remote, options = {}) # rubocop:disable Lint/UnusedMethodArgument
      end

      # Disconnect the session connection, if it is still active.
      def disconnect
      end

      # Returns the shell command that will log into an instance.
      #
      # @param state [Hash] mutable instance and driver state
      # @return [LoginCommand] an object containing the array of command line
      #   tokens and exec options to be used in a fork/exec
      # @raise [ActionFailed] if the action could not be completed
      def login_command
        raise ActionFailed, "Remote login is not supported in this transport."
      end

      # Blocks until the remote host is listening thru the transport.
      #
      # @param hostname [String] remote server host
      # @param username [String] username (default: `nil`)
      # @param options [Hash] configuration hash (default: `{}`)
      # @api private
      def wait_for_connection
        logger.info("Waiting for #{hostname}:#{port}...") until test_connection
      end

      # Returns the desired shell to use. 
      # [Idea] Let's see if this help for the Provisioner to chose the right code
      #
      # @return [String] the desired shell for this transport
      def shell
        config.fetch(:shell, nil)
      end

      # Returns the config[:sudo] parameter.
      # [Idea] Let's see if this help for the Provisioner to chose the right code
      #
      # @return [LoginCommand] an object containing the array of command line
      def sudo
        config.fetch(:sudo, nil)
      end

      # This will function as a guideline when nobody set the port
      # 
      # @return [Integer] Default port for this transport.
      def default_port
        @default_port ||= 1234
      end

      # Performs any final configuration required for the transport to do its
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
        load_needed_dependencies!
        self
      end

      private

      # Loads any required third party Ruby libraries or runs any shell out
      # commands to prepare the provisioner. This method will be called in the
      # context of the main thread of execution and so does not necessarily
      # have to be thread safe.
      #
      # **Note:** any subclasses overriding this method would be well advised
      # to call super when overriding this method, for example:
      #
      # @example overriding `#load_needed_dependencies!`
      #
      #   class MyTransport < Kitchen::Transport::Base
      #     def load_needed_dependencies!
      #       super
      #       # any further work
      #     end
      #   end
      #
      # @raise [ClientError] if any library loading fails or any of the
      #   dependency requirements cannot be satisfied
      # @api private
      def load_needed_dependencies!
      end

      # @return [String] the remote hostname
      # @api private
      attr_reader :hostname

      # @return [String] the username for the remote host
      # @api private
      attr_reader :username

      # @return [Hash] Transport options
      attr_reader :options

      # @return [Logger] the logger to use
      # @api private
      attr_reader :logger

      # Builds the Transport session connection or returns the existing one if
      # built.
      #
      # @return [Transport::Session] the Transport connection session
      # @api private
      def session
        @session ||= establish_connection
      end
      
      # Establish a connection session to the remote host.
      #
      # @return [Transport::Session] the Transport connection session
      # @api private
      def establish_connection
      end

      # @return [Integer] Transport port
      # @api private
      def port
        options.fetch(:port, default_port)
      end

      # String representation of object, reporting its connection details and
      # configuration.
      #
      # @api private
      def to_s
        "#{username}@#{hostname}:#{port}<#{options.inspect}>"
      end

      # Execute a remote command and return the command's exit code.
      #
      # @param command [String] command string to execute
      # @return [Integer] the exit code of the command
      # @api private
      def execute_with_exit(command) # rubocop:disable Lint/UnusedMethodArgument
      end

      # Returns a suitable logger to use for output.
      #
      # @return [Kitchen::Logger] a logger
      def logger
        instance ? instance.logger : Kitchen.logger
      end

      # Test a remote connectivity.
      #
      # @return [true,false] a truthy value if the connection is ready 
      # and false otherwise
      # @api private
      def test_connection
      end

      # Intercepts any bare #puts calls in subclasses and issues an INFO log
      # event instead.
      #
      # @param msg [String] message string
      def puts(msg) # rubocop:disable Lint/UnusedMethodArgument
        info(msg)
      end

      # Intercepts any bare #print calls in subclasses and issues an INFO log
      # event instead.
      #
      # @param msg [String] message string
      def print(msg) # rubocop:disable Lint/UnusedMethodArgument
        info(msg)
      end

      # Adds http and https proxy environment variables to a command, if set
      # in configuration data.
      #
      # @param command [String] command string
      # @return [String] command string
      # @api private
      def env_command(command) # rubocop:disable Lint/UnusedMethodArgument
      end

      # Builds arguments for constructing a `Kitchen::Transport` instance.
      #
      # @param state [Hash] state hash
      # @return [Hash] Options to build the transport
      # @api private
      def build_transport_args(state) # rubocop:disable Lint/UnusedMethodArgument
      end
    end
  end
end

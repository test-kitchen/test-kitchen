# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, Fletcher Nichol
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

require 'thor/util'

require 'kitchen/lazy_hash'

module Kitchen

  module Driver

    # Base class for a driver.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Base

      include ShellOut
      include Configurable
      include Logging

      def initialize(config = {})
        init_config(config)
      end

      # Returns the name of this driver, suitable for display in a CLI.
      #
      # @return [String] name of this driver
      def name
        self.class.name.split('::').last
      end

      # Creates an instance.
      #
      # @param state [Hash] mutable instance and driver state
      # @raise [ActionFailed] if the action could not be completed
      def create(state) ; end

      # Converges a running instance.
      #
      # @param state [Hash] mutable instance and driver state
      # @raise [ActionFailed] if the action could not be completed
      def converge(state) ; end

      # Sets up an instance.
      #
      # @param state [Hash] mutable instance and driver state
      # @raise [ActionFailed] if the action could not be completed
      def setup(state) ; end

      # Verifies a converged instance.
      #
      # @param state [Hash] mutable instance and driver state
      # @raise [ActionFailed] if the action could not be completed
      def verify(state) ; end

      # Destroys an instance.
      #
      # @param state [Hash] mutable instance and driver state
      # @raise [ActionFailed] if the action could not be completed
      def destroy(state) ; end

      # Returns the shell command that will log into an instance.
      #
      # @param state [Hash] mutable instance and driver state
      # @return [LoginCommand] an object containing the array of command line
      #   tokens and exec options to be used in a fork/exec
      # @raise [ActionFailed] if the action could not be completed
      def login_command(state)
        raise ActionFailed, "Remote login is not supported in this driver."
      end

      # Performs whatever tests that may be required to ensure that this driver
      # will be able to function in the current environment. This may involve
      # checking for the presence of certain directories, software installed,
      # etc.
      #
      # @raise [UserError] if the driver will not be able to perform or if a
      #   documented dependency is missing from the system
      def verify_dependencies ; end

      class << self
        # @return [Array<Symbol>] an array of action method names that cannot
        #   be run concurrently and must be run in serial via a shared mutex
        attr_reader :serial_actions
      end

      # Registers certain driver actions that cannot be safely run concurrently
      # in threads across multiple instances. Typically this might be used
      # for create or destroy actions that use an underlying resource that
      # cannot be used at the same time.
      #
      # A shared mutex for this driver object will be used to synchronize all
      # registered methods.
      #
      # @example a single action method that cannot be run concurrently
      #
      #   no_parallel_for :create
      #
      # @example multiple action methods that cannot be run concurrently
      #
      #   no_parallel_for :create, :destroy
      #
      # @param methods [Array<Symbol>] one or more actions as symbols
      # @raise [ClientError] if any method is not a valid action method name
      def self.no_parallel_for(*methods)
        Array(methods).each do |meth|
          if !ACTION_METHODS.include?(meth)
            raise ClientError, "##{meth} is not a valid no_parallel_for method"
          end
        end

        @serial_actions ||= []
        @serial_actions += methods
      end

      protected

      ACTION_METHODS = [:create, :converge, :setup, :verify, :destroy].freeze

      def logger
        instance ? instance.logger : Kitchen.logger
      end

      def puts(msg)
        info(msg)
      end

      def print(msg)
        info(msg)
      end

      def run_command(cmd, options = {})
        base_options = {
          :use_sudo => config[:use_sudo],
          :log_subject => Thor::Util.snake_case(self.class.to_s)
        }.merge(options)
        super(cmd, base_options)
      end

      def busser_setup_cmd
        busser.setup_cmd
      end

      def busser_sync_cmd
        busser.sync_cmd
      end

      def busser_run_cmd
        busser.run_cmd
      end

      def busser
        instance.busser
      end

    end
  end
end

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

module Kitchen

  module Driver

    # Base class for a driver.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Base

      include ShellOut
      include Logging

      attr_accessor :instance

      class << self
        attr_reader :serial_actions
      end

      def initialize(config = {})
        @config = LazyDriverHash.new(config, self)
        self.class.defaults.each do |attr, value|
          @config[attr] = value unless @config[attr]
        end
      end

      def validate_config!
        Array(self.class.validations).each do |tuple|
          tuple.last.call(tuple.first, config[tuple.first], self)
        end
      end

      # Returns the name of this driver, suitable for display in a CLI.
      #
      # @return [String] name of this driver
      def name
        self.class.name.split('::').last
      end

      # Provides hash-like access to configuration keys.
      #
      # @param attr [Object] configuration key
      # @return [Object] value at configuration key
      def [](attr)
        config[attr]
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

      protected

      attr_reader :config

      ACTION_METHODS = %w{create converge setup verify destroy}.
        map(&:to_sym).freeze

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
        test_root = File.join(config[:kitchen_root], 'test/integration')
        @busser ||= begin
          raise ClientError, "Instance must be set for Driver" if instance.nil?

          Busser.new(instance.suite.name, :test_root => test_root)
        end
      end

      def self.defaults
        @defaults ||= Hash.new.merge(super_defaults)
      end

      def self.super_defaults
        klass = self.superclass

        if klass.respond_to?(:defaults)
          klass.defaults
        else
          Hash.new
        end
      end

      def self.default_config(attr, value = nil, &block)
        defaults[attr] = block_given? ? block : value
      end

      def self.validations
        @validations
      end

      def self.required_config(attr, &block)
        @validations = [] if @validations.nil?
        if ! block_given?
          klass = self
          block = lambda do |attr, value, driver|
            if value.nil? || value.to_s.empty?
              attribute = "#{klass}#{driver.instance.to_str}#config[:#{attr}]"
              raise UserError, "#{attribute} cannot be blank"
            end
          end
        end
        @validations << [attr, block]
      end

      def self.no_parallel_for(*methods)
        Array(methods).each do |meth|
          if ! ACTION_METHODS.include?(meth)
            raise ClientError, "##{meth} is not a valid no_parallel_for method"
          end
        end

        @serial_actions ||= []
        @serial_actions += methods
      end

      # A modifed Hash object that may contain procs as a value which must be
      # executed in the context of a Driver object.
      #
      # @author Fletcher Nichol <fnichol@nichol.ca>
      class LazyDriverHash < SimpleDelegator

        def initialize(obj, driver)
          @driver = driver
          super(obj)
        end

        def [](key)
          proc_or_val = __getobj__[key]

          if proc_or_val.respond_to?(:call)
            proc_or_val.call(@driver)
          else
            proc_or_val
          end
        end
      end
    end
  end
end

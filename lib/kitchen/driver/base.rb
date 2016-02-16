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

require "kitchen/lazy_hash"

module Kitchen

  module Driver

    # Base class for a driver.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Base

      include Configurable
      include Logging

      # Creates a new Driver object using the provided configuration data
      # which will be merged with any default configuration.
      #
      # @param config [Hash] provided driver configuration
      def initialize(config = {})
        init_config(config)
      end

      # Creates an instance.
      #
      # @param state [Hash] mutable instance and driver state
      # @raise [ActionFailed] if the action could not be completed
      def create(state) # rubocop:disable Lint/UnusedMethodArgument
      end

      # Destroys an instance.
      #
      # @param state [Hash] mutable instance and driver state
      # @raise [ActionFailed] if the action could not be completed
      def destroy(state) # rubocop:disable Lint/UnusedMethodArgument
      end

      # Package an instance.
      #
      # @param state [Hash] mutable instance and driver state
      # @raise [ActionFailed] if the action could not be completed
      def package(state) # rubocop:disable Lint/UnusedMethodArgument
      end

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
        action_methods = [:create, :setup, :verify, :destroy]

        Array(methods).each do |meth|
          next if action_methods.include?(meth)

          raise ClientError, "##{meth} is not a valid no_parallel_for method"
        end

        @serial_actions ||= []
        @serial_actions += methods
      end

      # Sets the API version for this driver. If the driver does not set this
      # value, then `nil` will be used and reported.
      #
      # Sets the API version for this driver
      #
      # @example setting an API version
      #
      #   module Kitchen
      #     module Driver
      #       class NewDriver < Kitchen::Driver::Base
      #
      #         kitchen_driver_api_version 2
      #
      #       end
      #     end
      #   end
      #
      # @param version [Integer,String] a version number
      #
      def self.kitchen_driver_api_version(version)
        @api_version = version
      end

      private

      # Intercepts any bare #puts calls in subclasses and issues an INFO log
      # event instead.
      #
      # @param msg [String] message string
      def puts(msg)
        info(msg)
      end

      # Intercepts any bare #print calls in subclasses and issues an INFO log
      # event instead.
      #
      # @param msg [String] message string
      def print(msg)
        info(msg)
      end
    end
  end
end

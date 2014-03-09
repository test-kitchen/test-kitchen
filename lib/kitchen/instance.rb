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

require 'benchmark'
require 'fileutils'

module Kitchen

  # An instance of a suite running on a platform. A created instance may be a
  # local virtual machine, cloud instance, container, or even a bare metal
  # server, which is determined by the platform's driver.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Instance

    include Logging

    class << self
      attr_accessor :mutexes

      def name_for(suite, platform)
        "#{suite.name}-#{platform.name}".gsub(/_/, '-').gsub(/\./, '')
      end
    end

    # @return [Suite] the test suite configuration
    attr_reader :suite

    # @return [Platform] the target platform configuration
    attr_reader :platform

    # @return [String] name of this instance
    attr_reader :name

    # @return [Driver::Base] driver object which will manage this instance's
    #   lifecycle actions
    attr_reader :driver

    # @return [Provisioner::Base] provisioner object which will the setup
    #   and invocation instructions for configuration management and other
    #   automation tools
    attr_reader :provisioner

    # @return [Busser] busser object for instance to manage the busser
    #   installation on this instance
    attr_reader :busser

    # @return [Logger] the logger for this instance
    attr_reader :logger

    # Creates a new instance, given a suite and a platform.
    #
    # @param [Hash] options configuration for a new suite
    # @option options [Suite] :suite the suite (**Required)
    # @option options [Platform] :platform the platform (**Required)
    # @option options [Driver::Base] :driver the driver (**Required)
    # @option options [Provisioner::Base] :provisioner the provisioner
    #   (**Required)
    # @option options [Busser] :busser the busser logger (**Required**)
    # @option options [Logger] :logger the instance logger
    #   (default: Kitchen.logger)
    # @option options [StateFile] :state_file the state file object to use
    #   when tracking instance  state (**Required**)
    # @raise [ClientError] if one or more required options are omitted
    def initialize(options = {})
      validate_options(options)

      @suite        = options.fetch(:suite)
      @platform     = options.fetch(:platform)
      @name         = self.class.name_for(@suite, @platform)
      @driver       = options.fetch(:driver)
      @provisioner  = options.fetch(:provisioner)
      @busser       = options.fetch(:busser)
      @logger       = options.fetch(:logger) { Kitchen.logger }
      @state_file   = options.fetch(:state_file)

      setup_driver
      setup_provisioner
    end

    def to_str
      "<#{name}>"
    end

    # Creates this instance.
    #
    # @see Driver::Base#create
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Driver::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def create
      transition_to(:create)
    end

    # Converges this running instance.
    #
    # @see Driver::Base#converge
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Driver::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def converge
      transition_to(:converge)
    end

    # Sets up this converged instance for suite tests.
    #
    # @see Driver::Base#setup
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Driver::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def setup
      transition_to(:setup)
    end

    # Verifies this set up instance by executing suite tests.
    #
    # @see Driver::Base#verify
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Driver::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def verify
      transition_to(:verify)
    end

    # Destroys this instance.
    #
    # @see Driver::Base#destroy
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Driver::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def destroy
      transition_to(:destroy)
    end

    # Tests this instance by creating, converging and verifying. If this
    # instance is running, it will be pre-emptively destroyed to ensure a
    # clean slate. The instance will be left post-verify in a running state.
    #
    # @param destroy_mode [Symbol] strategy used to cleanup after instance
    #   has finished verifying (default: `:passing`)
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Driver::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def test(destroy_mode = :passing)
      elapsed = Benchmark.measure do
        banner "Cleaning up any prior instances of #{to_str}"
        destroy
        banner "Testing #{to_str}"
        verify
        destroy if destroy_mode == :passing
      end
      info "Finished testing #{to_str} #{Util.duration(elapsed.real)}."
      self
    ensure
      destroy if destroy_mode == :always
    end

    # Logs in to this instance by invoking a system command, provided by the
    # instance's driver. This could be an SSH command, telnet, or serial
    # console session.
    #
    # **Note** This method calls exec and will not return.
    #
    # @see Driver::LoginCommand
    # @see Driver::Base#login_command
    def login
      login_command = driver.login_command(state_file.read)
      command, *args = login_command.cmd_array
      options = login_command.options

      debug("Login command: #{command} #{args.join(' ')} (Options: #{options})")
      Kernel.exec(command, *args, options)
    end

    # Returns a Hash of configuration and other useful diagnostic information.
    #
    # @return [Hash] a diagnostic hash
    def diagnose
      result = Hash.new
      [:state_file, :driver, :provisioner, :busser].each do |sym|
        obj = send(sym)
        result[sym] = obj.respond_to?(:diagnose) ? obj.diagnose : :unknown
      end
      result
    end

    def last_action
      state_file.read[:last_action]
    end

    private

    attr_reader :state_file

    def validate_options(options)
      [:suite, :platform, :driver, :provisioner, :busser, :state_file].each do |k|
        if !options.key?(k)
          raise ClientError, "Instance#new requires option :#{k}"
        end
      end
    end

    def setup_driver
      @driver.instance = self
      @driver.validate_config!
      setup_driver_mutex
    end

    def setup_driver_mutex
      if driver.class.serial_actions
        Kitchen.mutex.synchronize do
          self.class.mutexes ||= Hash.new
          self.class.mutexes[driver.class] = Mutex.new
        end
      end
    end

    def setup_provisioner
      @provisioner.instance = self
    end

    def transition_to(desired)
      result = nil
      FSM.actions(last_action, desired).each do |transition|
        result = send("#{transition}_action")
      end
      result
    end

    def create_action
      perform_action(:create, "Creating")
    end

    def converge_action
      perform_action(:converge, "Converging")
    end

    def setup_action
      perform_action(:setup, "Setting up")
    end

    def verify_action
      perform_action(:verify, "Verifying")
    end

    def destroy_action
      perform_action(:destroy, "Destroying") { state_file.destroy }
    end

    def perform_action(verb, output_verb)
      banner "#{output_verb} #{to_str}..."
      elapsed = action(verb) { |state| driver.public_send(verb, state) }
      info("Finished #{output_verb.downcase} #{to_str}" +
        " #{Util.duration(elapsed.real)}.")
      yield if block_given?
      self
    end

    def action(what, &block)
      state = state_file.read
      elapsed = Benchmark.measure do
        synchronize_or_call(what, state, &block)
      end
      state[:last_action] = what.to_s
      elapsed
    rescue ActionFailed => e
      log_failure(what, e)
      raise(InstanceFailure, failure_message(what) +
        "  Please see .kitchen/logs/#{self.name}.log for more details",
        e.backtrace)
    rescue Exception => e
      log_failure(what, e)
      raise ActionFailed,
        "Failed to complete ##{what} action: [#{e.message}]", e.backtrace
    ensure
      state_file.write(state)
    end

    def synchronize_or_call(what, state, &block)
      if Array(driver.class.serial_actions).include?(what)
        debug("#{to_str} is synchronizing on #{driver.class}##{what}")
        self.class.mutexes[driver.class].synchronize do
          debug("#{to_str} is messaging #{driver.class}##{what}")
          block.call(state)
        end
      else
        block.call(state)
      end
    end

    def banner(*args)
      Kitchen.logger.logdev && Kitchen.logger.logdev.banner(*args)
      super
    end

    def log_failure(what, e)
      return if logger.logdev.nil?

      logger.logdev.error(failure_message(what))
      Error.formatted_trace(e).each { |line| logger.logdev.error(line) }
    end

    def failure_message(what)
      "#{what.capitalize} failed on instance #{self.to_str}."
    end

    # The simplest finite state machine pseudo-implementation needed to manage
    # an Instance.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class FSM

      # Returns an Array of all transitions to bring an Instance from its last
      # reported transistioned state into the desired transitioned state.
      #
      # @param last [String,Symbol,nil] the last known transitioned state of
      #   the Instance, defaulting to `nil` (for unknown or no history)
      # @param desired [String,Symbol] the desired transitioned state for the
      #   Instance
      # @return [Array<Symbol>] an Array of transition actions to perform
      def self.actions(last = nil, desired)
        last_index = index(last)
        desired_index = index(desired)

        if last_index == desired_index || last_index > desired_index
          Array(TRANSITIONS[desired_index])
        else
          TRANSITIONS.slice(last_index + 1, desired_index - last_index)
        end
      end

      private

      TRANSITIONS = [:destroy, :create, :converge, :setup, :verify]

      def self.index(transition)
        if transition.nil?
          0
        else
          TRANSITIONS.find_index { |t| t == transition.to_sym }
        end
      end
    end
  end
end

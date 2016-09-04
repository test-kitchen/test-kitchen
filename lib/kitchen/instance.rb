# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, 2013, 2014, Fletcher Nichol
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

require "benchmark"
require "fileutils"

module Kitchen

  # An instance of a suite running on a platform. A created instance may be a
  # local virtual machine, cloud instance, container, or even a bare metal
  # server, which is determined by the platform's driver.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Instance

    include Logging

    class << self

      # @return [Hash] a hash of mutxes, arranged by Driver class names
      # @api private
      attr_accessor :mutexes

      # Generates a name for an instance given a suite and platform.
      #
      # @param suite [Suite,#name] a Suite
      # @param platform [Platform,#name] a Platform
      # @return [String] a normalized, consistent name for an instance
      def name_for(suite, platform)
        "#{suite.name}-#{platform.name}".gsub(%r{[_,/]}, "-").gsub(/\./, "")
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

    # @return [Transport::Base] transport object which will communicate with
    #   an instance.
    attr_reader :transport

    # @return [Verifier] verifier object for instance to manage the verifier
    #   installation on this instance
    attr_reader :verifier

    # @return [Logger] the logger for this instance
    attr_reader :logger

    # Creates a new instance, given a suite and a platform.
    #
    # @param [Hash] options configuration for a new suite
    # @option options [Suite] :suite the suite (**Required**)
    # @option options [Platform] :platform the platform (**Required**)
    # @option options [Driver::Base] :driver the driver (**Required**)
    # @option options [Provisioner::Base] :provisioner the provisioner
    # @option options [Transport::Base] :transport the transport
    #   (**Required**)
    # @option options [Verifier] :verifier the verifier logger (**Required**)
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
      @transport    = options.fetch(:transport)
      @verifier     = options.fetch(:verifier)
      @logger       = options.fetch(:logger) { Kitchen.logger }
      @state_file   = options.fetch(:state_file)

      setup_driver
      setup_provisioner
      setup_transport
      setup_verifier
    end

    # Returns a displayable representation of the instance.
    #
    # @return [String] an instance display string
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
    # @see Provisioner::Base#call
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
    # instance's transport. This could be an SSH command, telnet, or serial
    # console session.
    #
    # **Note** This method calls exec and will not return.
    #
    # @see Kitchen::LoginCommand
    # @see Transport::Base::Connection#login_command
    def login
      state = state_file.read
      if state[:last_action].nil?
        raise UserError, "Instance #{to_str} has not yet been created"
      end

      lc = if legacy_ssh_base_driver?
        legacy_ssh_base_login(state)
      else
        transport.connection(state).login_command
      end

      debug(%{Login command: #{lc.command} #{lc.arguments.join(" ")} } \
        "(Options: #{lc.options})")
      Kernel.exec(*lc.exec_args)
    end

    # Executes an arbitrary command on this instance.
    #
    # @param command [String] a command string to execute
    def remote_exec(command)
      transport.connection(state_file.read) do |conn|
        conn.execute(command)
      end
    end

    # Perform package.
    #
    def package_action
      banner "Packaging remote instance"
      driver.package(state_file.read)
    end

    # Returns a Hash of configuration and other useful diagnostic information.
    #
    # @return [Hash] a diagnostic hash
    def diagnose
      result = Hash.new
      [
        :platform, :state_file, :driver, :provisioner, :transport, :verifier
      ].each do |sym|
        obj = send(sym)
        result[sym] = obj.respond_to?(:diagnose) ? obj.diagnose : :unknown
      end
      result
    end

    # Returns a Hash of configuration and other useful diagnostic information
    # associated with plugins (such as loaded version, class name, etc.).
    #
    # @return [Hash] a diagnostic hash
    def diagnose_plugins
      result = Hash.new
      [:driver, :provisioner, :verifier, :transport].each do |sym|
        obj = send(sym)
        result[sym] = if obj.respond_to?(:diagnose_plugin)
          obj.diagnose_plugin
        else
          :unknown
        end
      end
      result
    end

    # Returns the last successfully completed action state of the instance.
    #
    # @return [String] a named action which was last successfully completed
    def last_action
      state_file.read[:last_action]
    end

    # Clean up any per-instance resources before exiting.
    #
    # @return [void]
    def cleanup!
      @transport.cleanup! if @transport
    end

    private

    # @return [StateFile] a state file object that can be read from or written
    #   to
    # @api private
    attr_reader :state_file

    # Validate the initial internal state of this object and raising an
    # exception if any preconditions are not met.
    #
    # @param options[Hash] options hash passed into the constructor
    # @raise [ClientError] if any validations fail
    # @api private
    def validate_options(options)
      [
        :suite, :platform, :driver, :provisioner,
        :transport, :verifier, :state_file
      ].each do |k|
        next if options.key?(k)

        raise ClientError, "Instance#new requires option :#{k}"
      end
    end

    # Perform any final configuration or preparation needed for the driver
    # object carry out its duties.
    #
    # @api private
    def setup_driver
      @driver.finalize_config!(self)

      if driver.class.serial_actions
        Kitchen.mutex.synchronize do
          self.class.mutexes ||= Hash.new
          self.class.mutexes[driver.class] = Mutex.new
        end
      end
    end

    # Perform any final configuration or preparation needed for the provisioner
    # object carry out its duties.
    #
    # @api private
    def setup_provisioner
      @provisioner.finalize_config!(self)
    end

    # Perform any final configuration or preparation needed for the transport
    # object carry out its duties.
    #
    # @api private
    def setup_transport
      transport.finalize_config!(self)
    end

    # Perform any final configuration or preparation needed for the verifier
    # object carry out its duties.
    #
    # @api private
    def setup_verifier
      verifier.finalize_config!(self)
    end

    # Perform all actions in order from last state to desired state.
    #
    # @param desired [Symbol] a symbol representing the desired action state
    # @return [self] this instance, used to chain actions
    # @api private
    def transition_to(desired)
      result = nil
      FSM.actions(last_action, desired).each do |transition|
        result = send("#{transition}_action")
      end
      result
    end

    # Perform the create action.
    #
    # @see Driver::Base#create
    # @return [self] this instance, used to chain actions
    # @api private
    def create_action
      perform_action(:create, "Creating")
    end

    # Perform the converge action.
    #
    # @see Provisioner::Base#call
    # @return [self] this instance, used to chain actions
    # @api private
    def converge_action
      banner "Converging #{to_str}..."
      elapsed = action(:converge) do |state|
        if legacy_ssh_base_driver?
          legacy_ssh_base_converge(state)
        else
          provisioner.call(state)
        end
      end
      info("Finished converging #{to_str} #{Util.duration(elapsed.real)}.")
      self
    end

    # Perform the setup action.
    #
    # @see Driver::Base#setup
    # @return [self] this instance, used to chain actions
    # @api private
    def setup_action
      banner "Setting up #{to_str}..."
      elapsed = action(:setup) do |state|
        legacy_ssh_base_setup(state) if legacy_ssh_base_driver?
      end
      info("Finished setting up #{to_str} #{Util.duration(elapsed.real)}.")
      self
    end

    # returns true, if the verifier is busser
    def verifier_busser?(verifier)
      !defined?(Kitchen::Verifier::Busser).nil? && verifier.is_a?(Kitchen::Verifier::Busser)
    end

    # returns true, if the verifier is dummy
    def verifier_dummy?(verifier)
      !defined?(Kitchen::Verifier::Dummy).nil? && verifier.is_a?(Kitchen::Verifier::Dummy)
    end

    def use_legacy_ssh_verifier?(verifier)
      verifier_busser?(verifier) || verifier_dummy?(verifier)
    end

    # Perform the verify action.
    #
    # @see Driver::Base#verify
    # @return [self] this instance, used to chain actions
    # @api private
    def verify_action
      banner "Verifying #{to_str}..."
      elapsed = action(:verify) do |state|
        # use special handling for legacy driver
        if legacy_ssh_base_driver? && use_legacy_ssh_verifier?(verifier)
          legacy_ssh_base_verify(state)
        elsif legacy_ssh_base_driver?
          # read ssh options from legacy driver
          verifier.call(driver.legacy_state(state))
        else
          verifier.call(state)
        end
      end
      info("Finished verifying #{to_str} #{Util.duration(elapsed.real)}.")
      self
    end

    # Perform the destroy action.
    #
    # @see Driver::Base#destroy
    # @return [self] this instance, used to chain actions
    # @api private
    def destroy_action
      perform_action(:destroy, "Destroying") { state_file.destroy }
    end

    # Perform an arbitrary action and provide useful logging.
    #
    # @param verb [Symbol] the action to be performed
    # @param output_verb [String] a verb representing the action, suitable for
    #   use in output logging
    # @yield perform optional work just after action has complted
    # @return [self] this instance, used to chain actions
    # @api private
    def perform_action(verb, output_verb)
      banner "#{output_verb} #{to_str}..."
      elapsed = action(verb) { |state| driver.public_send(verb, state) }
      info("Finished #{output_verb.downcase} #{to_str}" \
        " #{Util.duration(elapsed.real)}.")
      yield if block_given?
      self
    end

    # Times a call to an action block and handles any raised exceptions. This
    # method ensures that the last successfully completed action is persisted
    # to the state file. The last action state will either be the desired
    # action that is passed in or the previous action that was persisted to the
    # state file.
    #
    # @param what [Symbol] the action to be performed
    # @param block [Proc] a block to be called
    # @return [Benchmark::Tms] timing information for the given action
    # @raise [InstanceFailed] if a driver action fails to complete, signaled
    #   by a driver raising an ActionFailed exception. Typical reasons for this
    #   would be a driver create action failing, a chef convergence crashing
    #   in normal course of development, failing acceptance tests in the
    #   verify action, etc.
    # @raise [ActionFailed] if an unforseen or unplanned exception is raised.
    #   This would usually indicate that a race condition was triggered, a
    #   bug exists in a driver, provisioner, or core, a transient IO error
    #   occured, etc.
    # @api private
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
        "  Please see .kitchen/logs/#{name}.log for more details",
        e.backtrace)
    rescue Exception => e # rubocop:disable Lint/RescueException
      log_failure(what, e)
      raise ActionFailed,
        "Failed to complete ##{what} action: [#{e.message}]", e.backtrace
    ensure
      state_file.write(state)
    end

    # Runs a given action block through a common driver mutex if required or
    # runs it directly otherwise. If a driver class' `.serial_actions` array
    # includes the desired action, then the action must be run with a muxtex
    # lock. Otherwise, it is assumed that the action can happen concurrently,
    # or fully in parallel.
    #
    # @param what [Symbol] the action to be performed
    # @param state [Hash] a mutable state hash for this instance
    # @param block [Proc] a block to be called
    # @api private
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

    # Writes a high level message for logging and/or output.
    #
    # In this case, all instance banner messages will be written to the common
    # Kitchen logger so that the high level flow of a run can be followed in
    # the kitchen.log file.
    #
    # @api private
    def banner(*args)
      Kitchen.logger.logdev && Kitchen.logger.logdev.banner(*args)
      super
    end

    # Logs a failure (message and backtrace) to the instance's file logger
    # to help with debugging and diagnosing issues without overwhelming the
    # console output in the default case (i.e. running kitchen with :info
    # level debugging).
    #
    # @param what [String] an action
    # @param e [Exception] an exception
    # @api private
    def log_failure(what, e)
      return if logger.logdev.nil?

      logger.logdev.error(failure_message(what))
      Error.formatted_trace(e).each { |line| logger.logdev.error(line) }
    end

    # Returns a string explaining what action failed, at a high level. Used
    # for displaying to end user.
    #
    # @param what [String] an action
    # @return [String] a failure message
    # @api private
    def failure_message(what)
      "#{what.capitalize} failed on instance #{to_str}."
    end

    # Invokes `Driver#converge` on a legacy Driver, which inherits from
    # `Kitchen::Driver::SSHBase`.
    #
    # @param state [Hash] mutable instance state
    # @deprecated When legacy Driver::SSHBase support is removed, the
    #   `#converge` method will no longer be called on the Driver.
    # @api private
    def legacy_ssh_base_converge(state)
      warn("Running legacy converge for '#{driver.name}' Driver")
      # TODO: Document upgrade path and provide link
      # warn("Driver authors: please read http://example.com for more details.")
      driver.converge(state)
    end

    # @return [TrueClass,FalseClass] whether or not the Driver inherits from
    #   `Kitchen::Driver::SSHBase`
    # @deprecated When legacy Driver::SSHBase support is removed, the
    #   `#converge` method will no longer be called on the Driver.
    # @api private
    def legacy_ssh_base_driver?
      driver.class < Kitchen::Driver::SSHBase
    end

    # Invokes `Driver#login_command` on a legacy Driver, which inherits from
    # `Kitchen::Driver::SSHBase`.
    #
    # @param state [Hash] mutable instance state
    # @deprecated When legacy Driver::SSHBase support is removed, the
    #   `#login_command` method will no longer be called on the Driver.
    # @api private
    def legacy_ssh_base_login(state)
      warn("Running legacy login for '#{driver.name}' Driver")
      # TODO: Document upgrade path and provide link
      # warn("Driver authors: please read http://example.com for more details.")
      driver.login_command(state)
    end

    # Invokes `Driver#setup` on a legacy Driver, which inherits from
    # `Kitchen::Driver::SSHBase`.
    #
    # @param state [Hash] mutable instance state
    # @deprecated When legacy Driver::SSHBase support is removed, the
    #   `#setup` method will no longer be called on the Driver.
    # @api private
    def legacy_ssh_base_setup(state)
      warn("Running legacy setup for '#{driver.name}' Driver")
      # TODO: Document upgrade path and provide link
      # warn("Driver authors: please read http://example.com for more details.")
      driver.setup(state)
    end

    # Invokes `Driver#verify` on a legacy Driver, which inherits from
    # `Kitchen::Driver::SSHBase`.
    #
    # @param state [Hash] mutable instance state
    # @deprecated When legacy Driver::SSHBase support is removed, the
    #   `#verify` method will no longer be called on the Driver.
    # @api private
    def legacy_ssh_base_verify(state)
      warn("Running legacy verify for '#{driver.name}' Driver")
      # TODO: Document upgrade path and provide link
      # warn("Driver authors: please read http://example.com for more details.")
      driver.verify(state)
    end

    # The simplest finite state machine pseudo-implementation needed to manage
    # an Instance.
    #
    # @api private
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
      # @api private
      def self.actions(last = nil, desired)
        last_index = index(last)
        desired_index = index(desired)

        if last_index == desired_index || last_index > desired_index
          Array(TRANSITIONS[desired_index])
        else
          TRANSITIONS.slice(last_index + 1, desired_index - last_index)
        end
      end

      TRANSITIONS = [:destroy, :create, :converge, :setup, :verify]

      # Determines the index of a state in the state lifecycle vector. Woah.
      #
      # @param transition [Symbol,#to_sym] a state
      # @param [Integer] the index position
      # @api private
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

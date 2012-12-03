# -*- encoding: utf-8 -*-

require 'mixlib/shellout'
require 'yaml'

require 'jamie/version'

module Jamie

  # A target operating system environment in which convergence integration
  # will take place. This may represent a specific operating system, version,
  # and machine architecture.
  class Platform

    # @return [String] logical name of this platform
    attr_reader :name

    # @return [String] optional type of driver plugin for use on this platform
    attr_reader :driver_plugin

    # @return [String] name of the Vagrant box to use for this platform
    attr_reader :vagrant_box

    # @return [String] URL to download the desired Vagrant box for this
    #   platform
    attr_reader :vagrant_box_url

    # @return [Array] Array of Chef run_list items that will be placed
    #   at the beginning of the run_list when a convergence is performed
    attr_reader :base_run_list

    # Constructs a new platform.
    #
    # @param [Hash] options yep
    # @option options [String] :name logical name of this platform
    #   (**Required**)
    # @option options [String] :driver_plugin optional type of driver plugin
    #   for use on this platform
    # @option options [String] :vagrant_box name of the Vagrant box to use
    #   for this platform
    # @option options [String] :vagrant_box_url URL to download the desired
    #   Vagrant box for this platform
    # @option options [Array<String>] :base_run_list Array of Chef run_list
    #   items that will be placed at the beginning of the run_list when a
    #   convergence is performed
    def initialize(options = {})
      validate_options(options)

      @name = options['name']
      @driver_plugin = options['driver_plugin']
      @vagrant_box = options['vagrant_box']
      @vagrant_box_url = options['vagrant_box_url']
      @base_run_list = Array(options['base_run_list'])
    end

    private

    def validate_options(options)
      if options['name'].nil?
        raise ArgumentError, "The option 'name' is required."
      end
    end
  end

  # A Chef run_list and attribute hash that will be used in a convergence
  # integration.
  class Suite

    # @return [String] logical name of this suite
    attr_reader :name

    # @return [Array] Array of Chef run_list items that will be placed
    #   after a Platform's base_run_list when a convergence is performed
    attr_reader :run_list

    # @return [Hash] Hash of Chef node attributes
    attr_reader :json

    # Constructs a new suite.
    #
    # @param [Hash] options yep
    # @option options [String] :name logical name of this suit (**Required**)
    # @option options [String] :run_list Array of Chef run_list items that
    #   will be placed after a Platform's base_run_list when a convergence
    #   is performed (**Required**)
    # @option options [String] :json
    def initialize(options = {})
      validate_options(options)

      @name = options['name']
      @run_list = options['run_list']
      @json = options['json'] || Hash.new
    end

    private

    def validate_options(options)
      if options['name'].nil?
        raise ArgumentError, "The option 'name' is required."
      end
      if options['run_list'].nil?
        raise ArgumentError, "The option 'run_list' is required."
      end
    end
  end

  # An instance of a suite running on a platform, managed by a driver.
  # A created instance may be a local virtual machine, cloud instance,
  # container, or even a bare metal server.
  class Instance

    # @return [Suite] the test suite configuration
    attr_reader :suite

    # @return [Platform] the target platform configuration
    attr_reader :platform

    # @return [Driver::Base] the driver which manages this instance
    attr_reader :driver

    # Creates a new instance, given a suite, platform, and Driver.
    #
    # @param suite [Suite] a suite
    # @param platform [Platform] a platform
    # @param driver [Driver::Base] a driver implementation
    def initialize(suite, platform, driver)
      @suite = suite
      @platform = platform
      @driver = driver
    end

    # @return [String] name of this instance
    def name
      "#{suite.name}-#{platform.name}".gsub(/_/, '-').gsub(/\./, '')
    end

    # Creates this instancea via its driver.
    #
    # @see Driver::Base#create
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Driver::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def create
      puts "-----> Creating instance #{name}"
      driver.create(self)
      puts "       Creation of instance #{name} complete."
      self
    end

    # Converges this running instance via its driver.
    #
    # @see Driver::Base#converge
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Driver::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def converge
      puts "-----> Converging instance #{name}"
      driver.converge(self)
      puts "       Convergence of instance #{name} complete."
      self
    end

    # Verifies this converged instance by executing tests via its driver.
    #
    # @see Driver::Base#verify
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Driver::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def verify
      puts "-----> Verifying instance #{name}"
      driver.verify(self)
      puts "       Verification of instance #{name} complete."
      self
    end

    # Destroys this instance via its driver.
    #
    # @see Driver::Base#destroy
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Driver::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def destroy
      puts "-----> Destroying instance #{name}"
      driver.destroy(self)
      puts "       Destruction of instance #{name} complete."
      self
    end

    # Tests this instance by creating, converging and verifying via its
    # driver. If this instance is running, it will be pre-emptively destroyed
    # to ensure a clean slate. The instance will be left post-verify in a
    # running state.
    #
    # @see #destroy
    # @see #create
    # @see #converge
    # @see #verify
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Driver::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def test
      puts "-----> Cleaning up any prior instances of #{name}"
      destroy
      puts "-----> Testing instance #{name}"
      create
      converge
      verify
      puts "       Testing of instance #{name} complete."
      self
    end
  end

  # Base configuration class for Jamie. This class exposes configuration such
  # as the location of the Jamie YAML file, instances, log_levels, etc.
  class Config

    attr_writer :yaml_file
    attr_writer :platforms
    attr_writer :suites
    attr_writer :log_level
    attr_writer :data_bags_base_path

    # Default path to the Jamie YAML file
    DEFAULT_YAML_FILE = File.join(Dir.pwd, '.jamie.yml').freeze

    # Default log level verbosity
    DEFAULT_LOG_LEVEL = :info

    # Default driver plugin to use
    DEFAULT_DRIVER_PLUGIN = "vagrant".freeze

    # Default base path which may contain `data_bags/` directories
    DEFAULT_DATA_BAGS_BASE_PATH = File.join(Dir.pwd, 'test/integration').freeze

    # @return [Array<Platform>] all defined platforms which will be used in
    #   convergence integration
    def platforms
      @platforms ||= Array(yaml["platforms"]).map { |hash| Platform.new(hash) }
    end

    # @return [Array<Suite>] all defined suites which will be used in
    #   convergence integration
    def suites
      @suites ||= Array(yaml["suites"]).map { |hash| Suite.new(hash) }
    end

    # @return [Array<Instance>] all instances, resulting from all platform and
    #   suite combinations
    def instances
      @instances ||= begin
        arr = []
        suites.each do |suite|
          platforms.each do |platform|
            plugin = platform.driver_plugin || yaml["driver_plugin"] ||
              DEFAULT_DRIVER_PLUGIN
            arr << Instance.new(suite, platform, Driver.for_plugin(plugin))
          end
        end
        arr
      end
    end

    # @return [String] path to the Jamie YAML file
    def yaml_file
      @yaml_file ||= DEFAULT_YAML_FILE
    end

    # @return [Symbol] log level verbosity
    def log_level
      @log_level ||= DEFAULT_LOG_LEVEL
    end

    # @return [String] base path that may contain a common `data_bags/`
    #   directory or an instance's `data_bags/` directory
    def data_bags_base_path
      @data_bags_path ||= DEFAULT_DATA_BAGS_BASE_PATH
    end

    private

    def yaml
      @yaml ||= YAML.load_file(File.expand_path(yaml_file))
    end
  end

  module Driver

    # Wrapped exception for any internally raised driver exceptions.
    class ActionFailed < StandardError ; end

    # Returns an instance of a driver given a plugin type string.
    #
    # @param plugin [String] a driver plugin type, which will be constantized
    # @return [Driver::Base] a driver instance
    def self.for_plugin(plugin)
      klass = self.const_get(plugin.capitalize)
      klass.new
    end

    # Base class for a driver. A driver is responsible for carrying out the
    # lifecycle activities of an instance, such as creating, converging, and
    # destroying an instance.
    class Base

      # Creates an instance.
      #
      # @param instance [Instance] an instance
      # @raise [ActionFailed] if the action could not be completed
      def create(instance) ; end

      # Converges a running instance.
      #
      # @param instance [Instance] an instance
      # @raise [ActionFailed] if the action could not be completed
      def converge(instance) ; end

      # Destroys an instance.
      #
      # @param instance [Instance] an instance
      # @raise [ActionFailed] if the action could not be completed
      def destroy(instance) ; end

      # Verifies a converged instance.
      #
      # @param instance [Instance] an instance
      # @raise [ActionFailed] if the action could not be completed
      def verify(instance)
        # Subclass may choose to implement
        puts "       Nothing to do!"
      end
    end

    # Vagrant driver for Jamie. It communicates to Vagrant via the CLI.
    class Vagrant < Jamie::Driver::Base

      def create(instance)
        run "vagrant up #{instance.name} --no-provision"
      end

      def converge(instance)
        run "vagrant provision #{instance.name}"
      end

      def destroy(instance)
        run "vagrant destroy #{instance.name} -f"
      end

      private

      def run(cmd)
        puts "       [vagrant command] '#{cmd}'"
        shellout = Mixlib::ShellOut.new(
          cmd, :live_stream => STDOUT, :timeout => 60000
        )
        shellout.run_command
        puts "       [vagrant command] '#{cmd}' ran " +
          "in #{shellout.execution_time} seconds."
        shellout.error!
      rescue Mixlib::ShellOut::ShellCommandFailed => ex
        raise ActionFailed, ex.message
      end
    end
  end
end

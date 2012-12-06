# -*- encoding: utf-8 -*-

require 'yaml'

require 'jamie/core_ext'
require 'jamie/version'

module Jamie

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

    # Creates a new configuration.
    #
    # @param yaml_file [String] optional path to Jamie YAML file
    def initialize(yaml_file = nil)
      @yaml_file = yaml_file
    end

    # @return [Array<Platform>] all defined platforms which will be used in
    #   convergence integration
    def platforms
      @platforms ||= Array(yaml["platforms"]).map { |hash| new_platform(hash) }
    end

    # @return [Array<Suite>] all defined suites which will be used in
    #   convergence integration
    def suites
      @suites ||= Array(yaml["suites"]).map { |hash| Suite.new(hash) }
    end

    # @return [Array<Instance>] all instances, resulting from all platform and
    #   suite combinations
    def instances
      @instances ||= suites.map { |suite|
        platforms.map { |platform| Instance.new(suite, platform) }
      }.flatten
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

    def new_platform(hash)
      mpc = merge_platform_config(hash)
      mpc['driver'] = new_driver(mpc['driver_plugin'], mpc['driver_config'])
      Platform.new(mpc)
    end

    def new_driver(plugin, config)
      Driver.for_plugin(plugin, config)
    end

    def yaml
      @yaml ||= YAML.load_file(File.expand_path(yaml_file)).rmerge(local_yaml)
    end

    def local_yaml_file
      std = File.expand_path(yaml_file)
      std.sub(/(#{File.extname(std)})$/, '.local\1')
    end

    def local_yaml
      @local_yaml ||= begin
        if File.exists?(local_yaml_file)
          YAML.load_file(local_yaml_file)
        else
          Hash.new
        end
      end
    end

    def merge_platform_config(platform_config)
      default_driver_config.rmerge(common_driver_config.rmerge(platform_config))
    end

    def default_driver_config
      { 'driver_plugin' => DEFAULT_DRIVER_PLUGIN }
    end

    def common_driver_config
      yaml.select { |key, value| %w(driver_plugin driver_config).include?(key) }
    end
  end

  # A Chef run_list and attribute hash that will be used in a convergence
  # integration.
  class Suite

    # @return [String] logical name of this suite
    attr_reader :name

    # @return [Array] Array of Chef run_list items
    attr_reader :run_list

    # @return [Hash] Hash of Chef node attributes
    attr_reader :json

    # Constructs a new suite.
    #
    # @param [Hash] options configuration for a new suite
    # @option options [String] :name logical name of this suit (**Required**)
    # @option options [String] :run_list Array of Chef run_list items
    #   (**Required**)
    # @option options [Hash] :json Hash of Chef node attributes
    def initialize(options = {})
      validate_options(options)

      @name = options['name']
      @run_list = options['run_list']
      @json = options['json'] || Hash.new
    end

    private

    def validate_options(opts)
      %w(name run_list).each do |k|
        raise ArgumentError, "Attribute '#{attr}' is required." if opts[k].nil?
      end
    end
  end

  # A target operating system environment in which convergence integration
  # will take place. This may represent a specific operating system, version,
  # and machine architecture.
  class Platform

    # @return [String] logical name of this platform
    attr_reader :name

    # @return [Driver::Base] driver object which will manage this platform's
    #   lifecycle actions
    attr_reader :driver

    # @return [Array] Array of Chef run_list items
    attr_reader :run_list

    # @return [Hash] Hash of Chef node attributes
    attr_reader :json

    # Constructs a new platform.
    #
    # @param [Hash] options configuration for a new platform
    # @option options [String] :name logical name of this platform
    #   (**Required**)
    # @option options [Driver::Base] :driver subclass of Driver::Base which
    #   will manage this platform's lifecycle actions (**Required**)
    # @option options [Array<String>] :run_list Array of Chef run_list
    #   items
    # @option options [Hash] :json Hash of Chef node attributes
    def initialize(options = {})
      validate_options(options)

      @name = options['name']
      @driver = options['driver']
      @run_list = Array(options['run_list'])
      @json = options['json'] || Hash.new
    end

    private

    def validate_options(opts)
      %w(name driver).each do |k|
        raise ArgumentError, "Attribute '#{attr}' is required." if opts[k].nil?
      end
    end
  end

  # An instance of a suite running on a platform. A created instance may be a
  # local virtual machine, cloud instance, container, or even a bare metal
  # server, which is determined by the platform's driver.
  class Instance

    # @return [Suite] the test suite configuration
    attr_reader :suite

    # @return [Platform] the target platform configuration
    attr_reader :platform

    # Creates a new instance, given a suite and a platform.
    #
    # @param suite [Suite] a suite
    # @param platform [Platform] a platform
    def initialize(suite, platform)
      @suite = suite
      @platform = platform
    end

    # @return [String] name of this instance
    def name
      "#{suite.name}-#{platform.name}".gsub(/_/, '-').gsub(/\./, '')
    end

    # Returns a combined run_list starting with the platform's run_list
    # followed by the suite's run_list.
    #
    # @return [Array] combined run_list from suite and platform
    def run_list
      Array(platform.run_list) + Array(suite.run_list)
    end

    # Returns a merged hash of Chef node attributes with values from the
    # suite overriding values from the platform.
    #
    # @return [Hash] merged hash of Chef node attributes
    def json
      platform.json.rmerge(suite.json)
    end

    # Creates this instance.
    #
    # @see Driver::Base#create
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Driver::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def create
      puts "-----> Creating instance #{name}"
      platform.driver.create(self)
      puts "       Creation of instance #{name} complete."
      self
    end

    # Converges this running instance.
    #
    # @see Driver::Base#converge
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Driver::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def converge
      puts "-----> Converging instance #{name}"
      platform.driver.converge(self)
      puts "       Convergence of instance #{name} complete."
      self
    end

    # Verifies this converged instance by executing tests.
    #
    # @see Driver::Base#verify
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Driver::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def verify
      puts "-----> Verifying instance #{name}"
      platform.driver.verify(self)
      puts "       Verification of instance #{name} complete."
      self
    end

    # Destroys this instance.
    #
    # @see Driver::Base#destroy
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Driver::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def destroy
      puts "-----> Destroying instance #{name}"
      platform.driver.destroy(self)
      puts "       Destruction of instance #{name} complete."
      self
    end

    # Tests this instance by creating, converging and verifying. If this
    # instance is running, it will be pre-emptively destroyed to ensure a
    # clean slate. The instance will be left post-verify in a running state.
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

  module Driver

    # Wrapped exception for any internally raised driver exceptions.
    class ActionFailed < StandardError ; end

    # Returns an instance of a driver given a plugin type string.
    #
    # @param plugin [String] a driver plugin type, which will be constantized
    # @return [Driver::Base] a driver instance
    def self.for_plugin(plugin, config)
      require "jamie/driver/#{plugin}"

      klass = self.const_get(plugin.capitalize)
      klass.new(config)
    end

    # Base class for a driver. A driver is responsible for carrying out the
    # lifecycle activities of an instance, such as creating, converging, and
    # destroying an instance.
    class Base

      def initialize(config)
        @config = config
        self.class.defaults.each do |attr, value|
          @config[attr] = value unless @config[attr]
        end
      end

      # Provides hash-like access to configuration keys.
      #
      # @param attr [Object] configuration key
      # @return [Object] value at configuration key
      def [](attr)
        @config[attr]
      end

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

      private

      def self.defaults
        @defaults ||= Hash.new
      end

      def self.default_config(attr, value)
        defaults[attr] = value
      end
    end
  end
end

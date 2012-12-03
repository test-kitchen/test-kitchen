# -*- encoding: utf-8 -*-

require 'hashie/dash'
require 'mixlib/shellout'
require 'yaml'

require "jamie/version"

module Jamie
  # A target operating system environment in which convergence integration
  # will take place. This may represent a specific operating system, version,
  # and machine architecture.
  class Platform < Hashie::Dash
    # @!attribute name
    #   @return [String] logical name of this platform
    property :name, :required => true

    # @!attribute backend_plugin
    #   @return [String] optional type of backend plugin for use on this
    #     platform
    #   @see Backend.for_plugin
    property :backend_plugin

    # @!attribute vagrant_box
    #   @return [String] name of the Vagrant box to use for this platform
    #   @see http://vagrantup.com/v1/docs/config/vm/box.html
    property :vagrant_box

    # @!attribute vagrant_box_url
    #   @return [String] URL to download the desired Vagrant box for this
    #     platform
    #   @see http://vagrantup.com/v1/docs/config/vm/box_url.html
    property :vagrant_box_url

    # @!attribute base_run_list
    #   @return [Array] Array of Chef run_list items that will be placed
    #     at the beginning of the run_list when a convergence is performed
    #   @example
    #     [ "recipe[apt]", "recipe[fix_something]" ]
    property :base_run_list, :default => []
  end

  # A Chef run_list and attribute hash that will be used in a convergence
  # integration.
  class Suite < Hashie::Dash
    # @!attribute name
    #   @return [String] logical name of this suite
    property :name, :required => true

    # @!attribute run_list
    #   @return [Array] Array of Chef run_list items that will be placed
    #     after a Platform's base_run_list when a convergence is performed
    #   @example
    #     [ "recipe[rvm::system]", "recipe[rvm::user]" ]
    property :run_list, :required => true

    # @!attribute json
    #   @return [Hash] Hash of Chef node attributes
    #   @example
    #     {
    #       "rvm" => {
    #         "user_installs" => [
    #           { "user" => "john" }
    #           { "user" => "jane" }
    #         ]
    #       }
    #     }
    property :json, :default => Hash.new
  end

  # An instance of a suite running on a platform, managed by a backend.
  # A created instance may be a local virtual machine, cloud instance,
  # container, or even a bare metal server.
  class Instance
    # @return [Suite] the test suite configuration
    attr_reader :suite

    # @return [Platform] the target platform configuration
    attr_reader :platform

    # @return [Backend::Base] the backend which manages this instance
    attr_reader :backend

    # Creates a new instance, given a suite, platform, and Backend.
    #
    # @param suite [Suite] a suite
    # @param platform [Platform] a platform
    # @param backend [Backend::Base] a backend implementation
    def initialize(suite, platform, backend)
      @suite = suite
      @platform = platform
      @backend = backend
    end

    # @return [String] name of this instance
    def name
      "#{suite.name}-#{platform.name}".gsub(/_/, '-').gsub(/\./, '')
    end

    # Creates this instancea via its backend.
    #
    # @see Backend::Base#create
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Backend::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def create
      puts "-----> Creating instance #{name}"
      backend.create(self)
      puts "       Creation of instance #{name} complete."
      self
    end

    # Converges this running instance via its backend.
    #
    # @see Backend::Base#converge
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Backend::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def converge
      puts "-----> Converging instance #{name}"
      backend.converge(self)
      puts "       Convergence of instance #{name} complete."
      self
    end

    # Verifies this converged instance by executing tests via its backend.
    #
    # @see Backend::Base#verify
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Backend::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def verify
      puts "-----> Verifying instance #{name}"
      backend.verify(self)
      puts "       Verification of instance #{name} complete."
      self
    end

    # Destroys this instance via its backend.
    #
    # @see Backend::Base#destroy
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Backend::ActionFailed and return some kind of null object
    #   to gracfully stop action chaining
    def destroy
      puts "-----> Destroying instance #{name}"
      backend.destroy(self)
      puts "       Destruction of instance #{name} complete."
      self
    end

    # Tests this instance by creating, converging and verifying via its
    # backend. If this instance is running, it will be pre-emptively destroyed
    # to ensure a clean slate. The instance will be left post-verify in a
    # running state.
    #
    # @see #destroy
    # @see #create
    # @see #converge
    # @see #verify
    # @return [self] this instance, used to chain actions
    #
    # @todo rescue Backend::ActionFailed and return some kind of null object
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

    # Default backend plugin to use
    DEFAULT_BACKEND_PLUGIN = "vagrant".freeze

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
            plugin = platform.backend_plugin || yaml["backend_plugin"] ||
              DEFAULT_BACKEND_PLUGIN
            arr << Instance.new(suite, platform, Backend.for_plugin(plugin))
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

  module Backend
    # Wrapped exception for any internally raised backend exceptions.
    class ActionFailed < StandardError ; end

    # Returns an instance of a backend given a plugin type string.
    #
    # @param plugin [String] a backend plugin type, which will be constantized
    # @return [Backend::Base] a backend instance
    def self.for_plugin(plugin)
      klass = self.const_get(plugin.capitalize)
      klass.new
    end

    # Base class for a backend. A backend is responsible for carrying out the
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

    # Vagrant backend for Jamie. It communicates to Vagrant via the CLI.
    class Vagrant < Jamie::Backend::Base
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

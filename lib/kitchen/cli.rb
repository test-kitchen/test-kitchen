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

require "thor"

require "kitchen"
require "kitchen/generator/driver_create"
require "kitchen/generator/init"

module Kitchen

  # The command line runner for Kitchen.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class CLI < Thor

    # Common module to load and invoke a CLI-implementation agnostic command.
    module PerformCommand

      # Perform a CLI subcommand.
      #
      # @param task [String] action to take, usually corresponding to the
      #   subcommand name
      # @param command [String] command class to create and invoke]
      # @param args [Array] remainder arguments from processed ARGV
      #   (default: `nil`)
      # @param additional_options [Hash] additional configuration needed to
      #   set up the command class (default: `{}`)
      def perform(task, command, args = nil, additional_options = {})
        require "kitchen/command/#{command}"

        command_options = {
          :action => task,
          :help => -> { help(task) },
          :config => @config,
          :shell => shell
        }.merge(additional_options)

        str_const = Thor::Util.camel_case(command)
        klass = ::Kitchen::Command.const_get(str_const)
        klass.new(args, options, command_options).call
      end
    end

    include Logging
    include PerformCommand

    # The maximum number of concurrent instances that can run--which is a bit
    # high
    MAX_CONCURRENCY = 9999

    attr_reader :config

    # Constructs a new instance.
    def initialize(*args)
      super
      $stdout.sync = true
      @loader = Kitchen::Loader::YAML.new(
        :project_config => ENV["KITCHEN_YAML"],
        :local_config => ENV["KITCHEN_LOCAL_YAML"],
        :global_config => ENV["KITCHEN_GLOBAL_YAML"]
      )
      @config = Kitchen::Config.new(
        :loader     => @loader
      )
      @config.log_level = Kitchen.env_log unless Kitchen.env_log.nil?
      @config.log_overwrite = Kitchen.env_log_overwrite unless Kitchen.env_log_overwrite.nil?
    end

    # Sets the logging method_options
    # @api private
    def self.log_options
      method_option :log_level,
        :aliases => "-l",
        :desc => "Set the log level (debug, info, warn, error, fatal)"
      method_option :log_overwrite,
        :desc => "Set to false to prevent log overwriting each time Test Kitchen runs",
        :type => :boolean
      method_option :color,
        :type => :boolean,
        :lazy_default => $stdout.tty?,
        :desc => "Toggle color output for STDOUT logger"
    end

    # Sets the test_base_path method_options
    # @api private
    def self.test_base_path
      method_option :test_base_path,
        :aliases => "-t",
        :desc => "Set the base path of the tests"
    end

    desc "list [INSTANCE|REGEXP|all]", "Lists one or more instances"
    method_option :bare,
      :aliases => "-b",
      :type => :boolean,
      :desc => "List the name of each instance only, one per line"
    method_option :json,
      :aliases => "-j",
      :type => :boolean,
      :desc => "Print data as JSON"
    method_option :debug,
      :aliases => "-d",
      :type => :boolean,
      :desc => "[Deprecated] Please use `kitchen diagnose'"
    log_options
    def list(*args)
      update_config!
      perform("list", "list", args)
    end
    map :status => :list

    desc "diagnose [INSTANCE|REGEXP|all]", "Show computed diagnostic configuration"
    method_option :loader,
      :type => :boolean,
      :desc => "Include data loader diagnostics"
    method_option :plugins,
      :type => :boolean,
      :desc => "Include plugin diagnostics"
    method_option :instances,
      :type => :boolean,
      :default => true,
      :desc => "Include instances diagnostics"
    method_option :all,
      :type => :boolean,
      :desc => "Include all diagnostics"
    log_options
    test_base_path
    def diagnose(*args)
      update_config!
      perform("diagnose", "diagnose", args, :loader => @loader)
    end

    {
      :create   => "Change instance state to create. " \
                   "Start one or more instances",
      :converge => "Change instance state to converge. " \
                   "Use a provisioner to configure one or more instances",
      :setup    => "Change instance state to setup. " \
                   "Prepare to run automated tests. " \
                   "Install busser and related gems on one or more instances",
      :verify   => "Change instance state to verify. " \
                   "Run automated tests on one or more instances",
      :destroy  => "Change instance state to destroy. " \
                   "Delete all information for one or more instances"
    }.each do |action, short_desc|
      desc(
        "#{action} [INSTANCE|REGEXP|all]",
        short_desc
      )
      long_desc <<-DESC
        The instance states are in order: destroy, create, converge, setup, verify, destroy.
        Change one or more instances from the current state to the #{action} state. Actions for all
        intermediate states will be executed. See http://kitchen.ci for further explanation.
      DESC
      method_option :concurrency,
        :aliases => "-c",
        :type => :numeric,
        :lazy_default => MAX_CONCURRENCY,
        :desc => <<-DESC.gsub(/^\s+/, "").gsub(/\n/, " ")
          Run a #{action} against all matching instances concurrently. Only N
          instances will run at the same time if a number is given.
        DESC
      method_option :parallel,
        :aliases => "-p",
        :type => :boolean,
        :desc => <<-DESC.gsub(/^\s+/, "").gsub(/\n/, " ")
          [Future DEPRECATION, use --concurrency]
          Run a #{action} against all matching instances concurrently.
        DESC
      test_base_path
      log_options
      define_method(action) do |*args|
        update_config!
        perform(action, "action", args)
      end
    end

    desc "test [INSTANCE|REGEXP|all]",
      "Test (destroy, create, converge, setup, verify and destroy) one or more instances"
    long_desc <<-DESC
      The instance states are in order: destroy, create, converge, setup, verify, destroy.
      Test changes the state of one or more instances to destroyed, then executes
      the actions for each state up to destroy. At any sign of failure, executing the
      actions stops and the instance is left in the last successful execution state.

      There are 3 post-verify modes for instance cleanup, triggered with
      the `--destroy' flag:

      * passing: instances passing verify will be destroyed afterwards.\n
      * always: instances will always be destroyed afterwards.\n
      * never: instances will never be destroyed afterwards.
    DESC
    method_option :concurrency,
      :aliases => "-c",
      :type => :numeric,
      :lazy_default => MAX_CONCURRENCY,
      :desc => <<-DESC.gsub(/^\s+/, "").gsub(/\n/, " ")
        Run a test against all matching instances concurrently. Only N
        instances will run at the same time if a number is given.
      DESC
    method_option :parallel,
      :aliases => "-p",
      :type => :boolean,
      :desc => <<-DESC.gsub(/^\s+/, "").gsub(/\n/, " ")
        [Future DEPRECATION, use --concurrency]
        Run a test against all matching instances concurrently.
      DESC
    method_option :destroy,
      :aliases => "-d",
      :default => "passing",
      :desc => "Destroy strategy to use after testing (passing, always, never)."
    method_option :auto_init,
      :type => :boolean,
      :default => false,
      :desc => "Invoke init command if .kitchen.yml is missing"
    test_base_path
    log_options
    def test(*args)
      update_config!
      ensure_initialized
      perform("test", "test", args)
    end

    desc "login INSTANCE|REGEXP", "Log in to one instance"
    log_options
    def login(*args)
      update_config!
      perform("login", "login", args)
    end

    desc "package INSTANCE|REGEXP", "package an instance"
    log_options
    def package(*args)
      update_config!
      perform("package", "package", args)
    end

    desc "exec INSTANCE|REGEXP -c REMOTE_COMMAND",
      "Execute command on one or more instance"
    method_option :command,
      :aliases => "-c",
      :desc => "execute via ssh"
    log_options
    def exec(*args)
      update_config!
      perform("exec", "exec", args)
    end

    desc "version", "Print Kitchen's version information"
    def version
      puts "Test Kitchen version #{Kitchen::VERSION}"
    end
    map %w[-v --version] => :version

    desc "sink", "Show the Kitchen sink!", :hide => true
    def sink
      perform("sink", "sink")
    end

    desc "console", "Kitchen Console!"
    def console
      perform("console", "console")
    end

    register Kitchen::Generator::Init, "init",
      "init", "Adds some configuration to your cookbook so Kitchen can rock"
    long_desc <<-D, :for => "init"
      Init will add Test Kitchen support to an existing project for
      convergence integration testing. A default .kitchen.yml file (which is
      intended to be customized) is created in the project's root directory
      and one or more gems will be added to the project's Gemfile.
    D
    tasks["init"].options = Kitchen::Generator::Init.class_options

    # Thor class for kitchen driver commands.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Driver < Thor

      include PerformCommand

      register Kitchen::Generator::DriverCreate, "create",
        "create [NAME]", "Create a new Kitchen Driver gem project"
      long_desc <<-D, :for => "create"
        Create will generate a project scaffold for a brand new Test Kitchen
        Driver RubyGem. For example:

        > kitchen driver create foobar

        will create a project scaffold for a RubyGem called `kitchen-foobar'.
      D
      tasks["create"].options = Kitchen::Generator::DriverCreate.class_options

      desc "discover", "Discover Test Kitchen drivers published on RubyGems"
      long_desc <<-D
        Discover will perform a search aginst the RubyGems service for any
        published gems of the form: "kitchen-*". Note that it it cannot be
        guarenteed that every result is a driver, but chances are good most
        relevant drivers will be returned.
      D
      method_option :chef_config_path,
        :default => nil,
        :desc => "Path to chef config file containing proxy configuration to use"
      def discover
        perform("discover", "driver_discover", args)
      end

      # @return [String] basename
      def self.basename
        super + " driver"
      end
    end

    register Kitchen::CLI::Driver, "driver",
      "driver", "Driver subcommands"

    no_tasks do
      def invoke_task(command, *args)
        if command.name == "help" && args.first.first == "driver"
          Kitchen::CLI::Driver.task_help(shell, args.first.last)
        else
          super
        end
      end
      alias_method :invoke_command, :invoke_task
    end

    private

    # Ensure the any failing commands exit non-zero.
    #
    # @return [true] you die always on failure
    # @api private
    def self.exit_on_failure?
      true
    end

    # @return [Logger] the common logger
    # @api private
    def logger
      Kitchen.logger
    end

    # Update and finalize options for logging, concurrency, and other concerns.
    #
    # @api private
    def update_config!
      @config.log_level = log_level if log_level

      unless options[:log_overwrite].nil?
        @config.log_overwrite = options[:log_overwrite]
      end
      @config.colorize = options[:color] unless options[:color].nil?

      if options[:test_base_path]
        # ensure we have an absolute path
        @config.test_base_path = File.absolute_path(options[:test_base_path])
      end

      # Now that we have required configs, lets create our file logger
      Kitchen.logger = Kitchen.default_file_logger(
        log_level,
        options[:log_overwrite]
      )

      update_parallel!
    end

    # Validate the log level from the config / CLI options, defaulting
    # to :info if the supplied level is empty or invalid
    #
    # @api private
    def log_level
      return unless options[:log_level]
      return @log_level if @log_level

      level = options[:log_level].downcase.to_sym
      unless valid_log_level?(level)
        level = :info
        banner "WARNING - invalid log level specified: " \
          "\"#{options[:log_level]}\" - reverting to :info log level."
      end

      @log_level = level
    end

    # Check to whether a provided log level is valid
    #
    # @api private
    def valid_log_level?(level)
      !Util.to_logger_level(level).nil?
    end

    # Set parallel concurrency options for Thor
    #
    # @api private
    def update_parallel!
      if options[:parallel]
        # warn here in a future release when option is used
        @options = Thor::CoreExt::HashWithIndifferentAccess.new(options.to_hash)
        if options[:parallel] && !options[:concurrency]
          options[:concurrency] = MAX_CONCURRENCY
        end
        options.delete(:parallel)
        options.freeze
      end
    end

    # If auto_init option is active, invoke the init generator.
    #
    # @api private
    def ensure_initialized
      yaml = ENV["KITCHEN_YAML"] || ".kitchen.yml"

      if options[:auto_init] && !File.exist?(yaml)
        banner "Invoking init as '#{yaml}' file is missing"
        invoke "init"
      end
    end
  end
end

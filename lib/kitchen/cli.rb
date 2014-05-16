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

require 'thor'

require 'kitchen'
require 'kitchen/generator/driver_create'
require 'kitchen/generator/init'
require 'kitchen/kitchen_action_handler'

require 'chef_metal/add_prefix_action_handler'
require 'chef/provider/machine'
require 'chef/knife'
require 'chef/config'
require 'chef/config_fetcher'
require 'chef/log'
require 'chef/application'

module Kitchen

  # The command line runner for Kitchen.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class CLI < Thor

    # Common module to load and invoke a CLI-implementation agnostic command.
    module PerformCommand

      def perform(task, command, args = nil, additional_options = {})
        require "kitchen/command/#{command}"

        command_options = {
          :action => task,
          :help => lambda { help(task) },
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

    MAX_CONCURRENCY = 9999

    # Constructs a new instance.
    def initialize(*args)
      super
      $stdout.sync = true
      Kitchen.logger = Kitchen.default_file_logger
      @loader = Kitchen::Loader::YAML.new(
        :project_config => ENV['KITCHEN_YAML'],
        :local_config => ENV['KITCHEN_LOCAL_YAML'],
        :global_config => ENV['KITCHEN_GLOBAL_YAML']
      )
      @config = Kitchen::Config.new(
        :loader     => @loader,
        :log_level  => ENV.fetch('KITCHEN_LOG', "info").downcase.to_sym
      )
    end

    desc "list [INSTANCE|REGEXP|all]", "Lists one or more instances"
    method_option :bare, :aliases => "-b", :type => :boolean,
      :desc => "List the name of each instance only, one per line"
    method_option :debug, :aliases => "-d", :type => :boolean,
      :desc => "[Deprecated] Please use `kitchen diagnose'"
    method_option :log_level, :aliases => "-l",
      :desc => "Set the log level (debug, info, warn, error, fatal)"
    def list(*args)
      update_config!
      perform("list", "list", args)
    end

    desc "diagnose [INSTANCE|REGEXP|all]", "Show computed diagnostic configuration"
    method_option :log_level, :aliases => "-l",
      :desc => "Set the log level (debug, info, warn, error, fatal)"
    method_option :loader, :type => :boolean,
      :desc => "Include data loader diagnostics"
    method_option :instances, :type => :boolean, :default => true,
      :desc => "Include instances diagnostics"
    method_option :all, :type => :boolean,
      :desc => "Include all diagnostics"
    def diagnose(*args)
      update_config!
      perform("diagnose", "diagnose", args, :loader => @loader)
    end

    def self.define_action(action)
      desc(
        "#{action} [INSTANCE|REGEXP|all]",
        "#{action.capitalize} one or more instances"
      )
      method_option :concurrency, :aliases => "-c",
        :type => :numeric, :lazy_default => MAX_CONCURRENCY,
        :desc => <<-DESC.gsub(/^\s+/, '').gsub(/\n/, ' ')
          Run a #{action} against all matching instances concurrently. Only N
          instances will run at the same time if a number is given.
        DESC
      method_option :parallel, :aliases => "-p", :type => :boolean,
        :desc => <<-DESC.gsub(/^\s+/, '').gsub(/\n/, ' ')
          [Future DEPRECATION, use --concurrency]
          Run a #{action} against all matching instances concurrently.
        DESC
      method_option :log_level, :aliases => "-l",
        :desc => "Set the log level (debug, info, warn, error, fatal)"
    end

    def self.define_standard_action(action)
      define_action(action)
      define_method(action) do |*args|
        update_config!
        perform(action, "action", args)
      end
    end

    define_action(:create)
    def create(*args)
      update_config!
      with_ready_machines do |machine|
        prefixed_handler = ChefMetal::AddPrefixActionHandler.new(action_handler, "[#{machine.name}] ")
        machine.setup_convergence(prefixed_handler)
      end
    end

    define_action(:converge)
    def converge(*args)
      update_config!
      with_ready_machines do |machine|
        prefixed_handler = ChefMetal::AddPrefixActionHandler.new(action_handler, "[#{machine.name}] ")
        machine.setup_convergence(prefixed_handler)
        machine.converge(prefixed_handler)
      end
    end

    define_action(:destroy)
    def destroy(*args)
      update_config!
      parallelizer.parallelize(@config.machine_specs_and_options_by_current_driver) do |driver, specs_and_options|
        @config.driver.delete_machines(action_handler, specs_and_options, parallelizer)
      end.to_a
    end

    no_commands do
      def with_ready_machines(&block)
        parallelizer.parallelize(@config.machine_specs_and_options_by_new_driver) do |driver, specs_and_options|
          driver.allocate_machines(action_handler, @config.machine_specs_and_options, parallelizer)
          driver.ready_machines(action_handler, @config.machine_specs_to_options, parallelizer, &block)
        end.to_a
      end

      def action_handler
        @action_handler ||= KitchenActionHandler.new
      end

      def parallelizer
        @parallelizer ||= begin
          threads = 0
          if options[:parallel]
            threads = (options[:concurrency] || MAX_CONCURRENCY) - 1
          end
          Chef::ChefFS::Parallelizer.new(threads)
        end
      end
    end

    [:setup, :verify].each do |action|
      define_standard_action(action)
    end

    define_action(:test)
    long_desc <<-DESC
      Test one or more instances

      There are 3 post-verify modes for instance cleanup, triggered with
      the `--destroy' flag:

      * passing: instances passing verify will be destroyed afterwards.\n
      * always: instances will always be destroyed afterwards.\n
      * never: instances will never be destroyed afterwards.
    DESC
    method_option :destroy, :aliases => "-d", :default => "passing",
      :desc => "Destroy strategy to use after testing (passing, always, never)."
    method_option :auto_init, :type => :boolean, :default => false,
      :desc => "Invoke init command if .kitchen.yml is missing"
    def test(*args)
      update_config!
      ensure_initialized
      perform("test", "test", args)
    end

    desc "login INSTANCE|REGEXP", "Log in to one instance"
    method_option :log_level, :aliases => "-l",
      :desc => "Set the log level (debug, info, warn, error, fatal)"
    def login(*args)
      update_config!
      perform("login", "login", args)
    end

    desc "exec INSTANCE|REGEXP -c REMOTE_COMMAND", "Execute command on one or more instance"
    method_option :log_level, :aliases => "-l",
      :desc => "Set the log level (debug, info, warn, error, fatal)"
    method_option :command, :aliases => "-c",
      :desc => "execute via ssh"
    def exec(*args)
      update_config!
      perform("exec", "exec", args)
    end

    desc "version", "Print Kitchen's version information"
    def version
      puts "Test Kitchen version #{Kitchen::VERSION}"
    end
    map %w(-v --version) => :version

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
      def discover
        perform("discover", "driver_discover", args)
      end

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

    def self.exit_on_failure?
      true
    end

    def logger
      Kitchen.logger
    end

    def update_config!
      if options[:log_level]
        level = options[:log_level].downcase.to_sym
        @config.log_level = level
        Kitchen.logger.level = Util.to_logger_level(level)
      end

      if options[:parallel]
        # warn here in a future release when option is used
        @options = Thor::CoreExt::HashWithIndifferentAccess.new(options.to_hash)
        if options[:parallel] && !options[:concurrency]
          options[:concurrency] = MAX_CONCURRENCY
        end
        options.delete(:parallel)
        options.freeze
      end

      Chef::Config.config_file = Chef::Knife.locate_config_file
      config_fetcher = Chef::ConfigFetcher.new(Chef::Config.config_file, Chef::Config.config_file_jail)
      if Chef::Config.config_file.nil?
        Chef::Log.warn("No config file found or specified on command line, using command line options.")
      elsif config_fetcher.config_missing?
        Chef::Log.warn("*****************************************")
        Chef::Log.warn("Did not find config file: #{Chef::Config.config_file}, using command line options.")
        Chef::Log.warn("*****************************************")
      else
        config_content = config_fetcher.read_config
        config_file_path = Chef::Config.config_file
        begin
          Chef::Config.from_string(config_content, config_file_path)
        rescue Exception => error
          Chef::Log.fatal("Configuration error #{error.class}: #{error.message}")
          filtered_trace = error.backtrace.grep(/#{Regexp.escape(config_file_path)}/)
          filtered_trace.each {|line| Chef::Log.fatal("  " + line )}
          Chef::Application.fatal!("Aborting due to error in '#{config_file_path}'", 2)
        end
      end


    end

    def ensure_initialized
      yaml = ENV['KITCHEN_YAML'] || '.kitchen.yml'

      if options[:auto_init] && ! File.exists?(yaml)
        banner "Invoking init as '#{yaml}' file is missing"
        invoke "init"
      end
    end
  end
end

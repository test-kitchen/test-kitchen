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
require 'erb'
require 'ostruct'
require 'thor'

require 'kitchen'
require 'kitchen/generator/init'
require 'kitchen/generator/new_plugin'

module Kitchen

  # The command line runner for Kitchen.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class CLI < Thor

    include Thor::Actions
    include Logging

    # Constructs a new instance.
    def initialize(*args)
      super
      $stdout.sync = true
      @config = Kitchen::Config.new(
        :loader     => Kitchen::Loader::YAML.new(ENV['KITCHEN_YAML']),
        :log_level  => ENV['KITCHEN_LOG'] && ENV['KITCHEN_LOG'].downcase.to_sym,
        :supervised => false
      )
      Kitchen.logger = Kitchen.default_file_logger
    end

    desc "list [(all|<REGEX>)]", "List all instances"
    method_option :bare, :aliases => "-b", :type => :boolean,
      :desc => "List the name of each instance only, one per line"
    def list(*args)
      result = parse_subcommand(args.first)
      if options[:bare]
        say Array(result).map { |i| i.name }.join("\n")
      else
        table = [
          [set_color("Instance", :green), set_color("Last Action", :green)]
        ]
        table += Array(result).map { |i| display_instance(i) }
        print_table(table)
      end
    end

    [:create, :converge, :setup, :verify, :destroy].each do |action|
      desc(
        "#{action} [(all|<REGEX>)] [opts]",
        "#{action.capitalize} one or more instances"
      )
      method_option :parallel, :aliases => "-p", :type => :boolean,
        :desc => "Perform action against all matching instances in parallel"
      method_option :log_level, :aliases => "-l",
        :desc => "Set the log level (debug, info, warn, error, fatal)"
      define_method(action) { |*args| exec_action(action) }
    end

    desc "test [all|<REGEX>)] [opts]", "Test one or more instances"
    long_desc <<-DESC
      Test one or more instances

      There are 3 post-verify modes for instance cleanup, triggered with
      the `--destroy' flag:

      * passing: instances passing verify will be destroyed afterwards.\n
      * always: instances will always be destroyed afterwards.\n
      * never: instances will never be destroyed afterwards.
    DESC
    method_option :parallel, :aliases => "-p", :type => :boolean,
      :desc => "Perform action against all matching instances in parallel"
    method_option :log_level, :aliases => "-l",
      :desc => "Set the log level (debug, info, warn, error, fatal)"
    method_option :destroy, :aliases => "-d", :default => "passing",
      :desc => "Destroy strategy to use after testing (passing, always, never)."
    method_option :auto_init, :type => :boolean, :default => false,
      :desc => "Invoke init command if .kitchen.yml is missing"
    def test(*args)
      if ! %w{passing always never}.include?(options[:destroy])
        raise ArgumentError, "Destroy mode must be passing, always, or never."
      end

      update_config!
      banner "Starting Kitchen"
      elapsed = Benchmark.measure do
        ensure_initialized
        destroy_mode = options[:destroy].to_sym
        @task = :test
        results = parse_subcommand(args.first)

        if options[:parallel]
          run_parallel(results, destroy_mode)
        else
          run_serial(results, destroy_mode)
        end
      end
      banner "Kitchen is finished. #{Util.duration(elapsed.real)}"
    end

    desc "login (['REGEX']|[INSTANCE])", "Log in to one instance"
    method_option :log_level, :aliases => "-l",
      :desc => "Set the log level (debug, info, warn, error, fatal)"
    def login(regexp)
      update_config!
      results = get_filtered_instances(regexp)
      if results.size > 1
        die task, "Argument `#{regexp}' returned multiple results:\n" +
          results.map { |i| "  * #{i.name}" }.join("\n")
      end
      instance = results.pop

      instance.login
    end

    desc "version", "Print Kitchen's version information"
    def version
      say "Test Kitchen version #{Kitchen::VERSION}"
    end
    map %w(-v --version) => :version

    desc "console", "Kitchen Console!"
    def console
      require 'pry'
      Pry.start(@config, :prompt => pry_prompts)
    rescue LoadError => e
      warn %{Make sure you have the pry gem installed. You can install it with:}
      warn %{`gem install pry` or including 'gem "pry"' in your Gemfile.}
      exit 1
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

      register Kitchen::Generator::NewPlugin, "create",
        "create [NAME]", "Create a new Kitchen Driver gem project"
      long_desc <<-D, :for => "create"
        Create will generate a project scaffold for a brand new Test Kitchen
        Driver RubyGem. For example:

        > kitchen driver create foobar

        will create a project scaffold for a RubyGem called `kitchen-foobar'.
      D
      tasks["create"].options = Kitchen::Generator::NewPlugin.class_options

      desc "discover", "Discover Test Kitchen drivers published on RubyGems"
      long_desc <<-D
        Discover will perform a search aginst the RubyGems service for any
        published gems of the form: "kitchen-*". Note that it it cannot be
        guarenteed that every result is a driver, but chances are good most
        relevant drivers will be returned.
      D
      def discover
        specs = fetch_gem_specs.sort { |x, y| x[0] <=> y[0] }
        specs = specs[0, 49].push(["...", "..."]) if specs.size > 49
        specs = specs.unshift(["Gem Name", "Latest Stable Release"])
        print_table(specs, :indent => 4)
      end

      def self.basename
        super + " driver"
      end

      private

      def fetch_gem_specs
        require 'rubygems/spec_fetcher'
        SafeYAML::OPTIONS[:suppress_warnings] = true
        req = Gem::Requirement.default
        dep = Gem::Deprecate.skip_during do
          Gem::Dependency.new(/kitchen-/i, req)
        end
        fetcher = Gem::SpecFetcher.fetcher

        specs = if fetcher.respond_to?(:find_matching)
          fetch_gem_specs_pre_rubygems_2(fetcher, dep)
        else
          fetch_gem_specs_post_rubygems_2(fetcher, dep)
        end
      end

      def fetch_gem_specs_pre_rubygems_2(fetcher, dep)
        specs = fetcher.find_matching(dep, false, false, false)
        specs.map { |t| t.first }.map { |t| t[0, 2] }
      end

      def fetch_gem_specs_post_rubygems_2(fetcher, dep)
        specs = fetcher.spec_for_dependency(dep, false)
        specs.first.map { |t| [t.first.name, t.first.version] }
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

    attr_reader :task

    def logger
      Kitchen.logger
    end

    def exec_action(action)
      update_config!
      banner "Starting Kitchen"
      elapsed = Benchmark.measure do
        @task = action
        results = parse_subcommand(args.first)
        options[:parallel] ? run_parallel(results) : run_serial(results)
      end
      banner "Kitchen is finished. #{Util.duration(elapsed.real)}"
    end

    def run_serial(instances, *args)
      Array(instances).map { |i| i.public_send(task, *args) }
    end

    def run_parallel(instances, *args)
      futures = Array(instances).map { |i| i.future.public_send(task) }
      futures.map { |i| i.value }
    end

    def parse_subcommand(arg = nil)
      arg == "all" ? get_all_instances : get_filtered_instances(arg)
    end

    def get_all_instances
      result = if options[:parallel]
        @config.instance_actors
      else
        @config.instances
      end

      if result.empty?
        die task, "No instances defined"
      else
        result
      end
    end

    def get_filtered_instances(regexp)
      result = if options[:parallel]
        @config.instance_actors(/#{regexp}/)
      else
        @config.instances.get_all(/#{regexp}/)
      end

      if result.empty?
        die task, "No instances for regex `#{regexp}', try running `kitchen list'"
      else
        result
      end
    end

    def display_instance(instance)
      action = case instance.last_action
      when 'create' then set_color("Created", :cyan)
      when 'converge' then set_color("Converged", :magenta)
      when 'setup' then set_color("Set Up", :blue)
      when 'verify' then set_color("Verified", :yellow)
      when nil then set_color("<Not Created>", :red)
      else set_color("<Unknown>", :white)
      end
      [set_color(instance.name, :white), action]
    end

    def update_config!
      if options[:log_level]
        @config.log_level = options[:log_level].downcase.to_sym
      end
    end

    def die(task, msg)
      error "\n#{msg}\n\n"
      help(task)
      exit 1
    end

    def ensure_initialized
      yaml = ENV['KITCHEN_YAML'] || '.kitchen.yml'

      if options[:auto_init] && ! File.exists?(yaml)
        banner "Invoking init as '#{yaml}' file is missing"
        invoke "init"
      end
    end

    def pry_prompts
      [
        proc { |target_self, nest_level, pry|
          ["[#{pry.input_array.size}] ",
            "kc(#{Pry.view_clip(target_self.class)})",
            "#{":#{nest_level}" unless nest_level.zero?}> "
          ].join
        },
        proc { |target_self, nest_level, pry|
          ["[#{pry.input_array.size}] ",
            "kc(#{Pry.view_clip(target_self.class)})",
            "#{":#{nest_level}" unless nest_level.zero?}* "
          ].join
        },
      ]
    end
  end
end

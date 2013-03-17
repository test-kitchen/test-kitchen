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
    method_option :destroy, :aliases => "-d", :default => "passing",
      :desc => "Destroy strategy to use after testing (passing, always, never)."
    def test(*args)
      if ! %w{passing always never}.include?(options[:destroy])
        raise ArgumentError, "Destroy mode must be passing, always, or never."
      end

      banner "Starting Kitchen"
      elapsed = Benchmark.measure do
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
    def login(regexp)
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
      say "Kitchen version #{Kitchen::VERSION}"
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
    all_tasks["init"].options = Kitchen::Generator::Init.class_options

    register Kitchen::Generator::NewPlugin, "new_plugin",
      "new_plugin [NAME]", "Generate a new Kitchen Driver plugin gem project"
    all_tasks["new_plugin"].options = Kitchen::Generator::NewPlugin.class_options

    private

    attr_reader :task

    def logger
      Kitchen.logger
    end

    def exec_action(action)
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
      result = @config.instances
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

    def die(task, msg)
      error "\n#{msg}\n\n"
      help(task)
      exit 1
    end

    def pry_prompts
      [
        proc { |target_self, nest_level, pry|
          ["[#{pry.input_array.size}] ",
            "jc(#{Pry.view_clip(target_self.class)})",
            "#{":#{nest_level}" unless nest_level.zero?}> "
          ].join
        },
        proc { |target_self, nest_level, pry|
          ["[#{pry.input_array.size}] ",
            "jc(#{Pry.view_clip(target_self.class)})",
            "#{":#{nest_level}" unless nest_level.zero?}* "
          ].join
        },
      ]
    end
  end
end

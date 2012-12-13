# -*- encoding: utf-8 -*-

require 'thor'

require 'jamie'

module Jamie

  # The command line runner for Jamie.
  class CLI < Thor

    # Constructs a new instance.
    def initialize(*args)
      super
      @config = Jamie::Config.new(ENV['JAMIE_YAML'])
    end

    desc "list (all ['REGEX']|[INSTANCE])", "List all instances"
    def list(*args)
      result = parse_subcommand(args[0], args[1])
      say Array(result).map{ |i| i.name }.join("\n")
    end

    [:create, :converge, :setup, :verify, :test, :destroy].each do |action|
      desc(
        "#{action} (all ['REGEX']|[INSTANCE])",
        "#{action.capitalize} one or more instances"
      )
      define_method(action) { |*args| exec_action(action) }
    end

    private

    attr_reader :task

    def exec_action(action)
      @task = action
      result = parse_subcommand(args[0], args[1])
      Array(result).each { |instance| instance.send(task) }
    end

    def parse_subcommand(name_or_all, regexp)
      if name_or_all.nil? || (name_or_all == "all" && regexp.nil?)
        get_all_instances
      elsif name_or_all == "all" && regexp
        get_filtered_instances(regexp)
      elsif name_or_all != "all" && regexp.nil?
        get_instance(name_or_all)
      else
        die task, "Invalid invocation."
      end
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
      result = @config.instances.get_all(/#{regexp}/)
      if result.empty?
        die task, "No instances for regex `#{regexp}', try running `jamie list'"
      else
        result
      end
    end

    def get_instance(name)
      result = @config.instances.get(name)
      if result.nil?
        die task, "No instance `#{name}', try running `jamie list'"
      end
      result
    end

    def die(task, msg)
      error "\n#{msg}\n\n"
      help(task)
      exit 1
    end
  end
end

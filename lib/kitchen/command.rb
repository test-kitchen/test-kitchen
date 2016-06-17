# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

require "thread"

module Kitchen

  module Command

    # Base class for CLI commands.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Base

      include Logging

      # Contstructs a new Command object.
      #
      # @param cmd_args [Array] remainder of the arguments from processed ARGV
      # @param cmd_options [Hash] hash of Thor options
      # @param options [Hash] configuration options
      # @option options [String] :action action to take, usually corresponding
      #   to the subcommand name (default: `nil`)
      # @option options [proc] :help a callable that displays help for the
      #   command
      # @option options [Config] :config a Config object (default: `nil`)
      # @option options [Loader] :loader a Loader object (default: `nil`)
      # @option options [String] :shell a Thor shell object
      def initialize(cmd_args, cmd_options, options = {})
        @args = cmd_args
        @options = cmd_options
        @action = options.fetch(:action, nil)
        @help = options.fetch(:help, -> { "No help provided" })
        @config = options.fetch(:config, nil)
        @loader = options.fetch(:loader, nil)
        @shell = options.fetch(:shell)
      end

      private

      # @return [Array] remainder of the arguments from processed ARGV
      # @api private
      attr_reader :args

      # @return [Hash] hash of Thor options
      # @api private
      attr_reader :options

      # @return [proc] a callable that displays help for the command
      # @api private
      attr_reader :help

      # @return [Config] a Config object
      # @api private
      attr_reader :config

      # @return [Thor::Shell] a Thor shell object
      # @api private
      attr_reader :shell

      # @return [String] the action to perform
      # @api private
      attr_reader :action

      # Emit an error message, display contextual help and then exit with a
      # non-zero exit code.
      #
      # **Note** This method calls exit and will not return.
      #
      # @param msg [String] error message
      # @api private
      def die(msg)
        error "\n#{msg}\n\n"
        help.call
        exit 1
      end

      # @return [Array<Instance>] an array of instances
      # @raise [SystemExit] if no instances are returned
      # @api private
      def all_instances
        result = @config.instances

        if result.empty?
          die "No instances defined"
        else
          result
        end
      end

      # Return an array on instances whos name matches the regular expression.
      #
      # @param regexp [Regexp] a regular expression matching on instance names
      # @return [Array<Instance>] an array of instances
      # @raise [SystemExit] if no instances are returned or the regular
      #   expression is invalid
      # @api private
      def filtered_instances(regexp)
        result = begin
          @config.instances.get(regexp) ||
            @config.instances.get_all(/#{regexp}/)
        rescue RegexpError => e
          die "Invalid Ruby regular expression, " \
            "you may need to single quote the argument. " \
            "Please try again or consult http://rubular.com/ (#{e.message})"
        end
        result = Array(result)

        if result.empty?
          die "No instances for regex `#{regexp}', try running `kitchen list'"
        else
          result
        end
      end

      # @return [Logger] the common logger
      # @api private
      def logger
        Kitchen.logger
      end

      # Return an array on instances whos name matches the regular expression,
      # the full instance name, or  the `"all"` literal.
      #
      # @param arg [String] an instance name, a regular expression, the literal
      #   `"all"`, or `nil`
      # @return [Array<Instance>] an array of instances
      # @api private
      def parse_subcommand(arg = nil)
        arg == "all" ? all_instances : filtered_instances(arg)
      end
    end

    # Common module to execute a Kitchen action such as create, converge, etc.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    module RunAction

      # Run an instance action (create, converge, setup, verify, destroy) on
      # a collection of instances. The instance actions will take place in a
      # seperate thread of execution which may or may not be running
      # concurrently.
      #
      # @param action [String] action to perform
      # @param instances [Array<Instance>] an array of instances
      def run_action(action, instances, *args)
        concurrency = concurrency_setting(instances)

        queue = Queue.new
        instances.each { |i| queue << i }
        concurrency.times { queue << nil }

        threads = []
        @action_errors = []
        concurrency.times do
          threads << Thread.new do
            while instance = queue.pop
              run_action_in_thread(action, instance, *args)
            end
          end
        end
        threads.map(&:join)
        report_errors
      end

      # private

      def report_errors
        unless @action_errors.empty?
          msg = ["#{@action_errors.length} actions failed.",
                 @action_errors.map { |e| ">>>>>>     #{e.message}" }].join("\n")
          raise ActionFailed.new(msg, @action_errors)
        end
      end

      def concurrency_setting(instances)
        concurrency = 1
        if options[:concurrency]
          concurrency = options[:concurrency] || instances.size
          concurrency = instances.size if concurrency > instances.size
        end
        concurrency
      end

      def run_action_in_thread(action, instance, *args)
        instance.public_send(action, *args)
      rescue Kitchen::InstanceFailure => e
        @action_errors << e
      rescue Kitchen::ActionFailed => e
        new_error = Kitchen::ActionFailed.new("#{e.message} on #{instance.name}")
        new_error.set_backtrace(e.backtrace)
        @action_errors << new_error
      ensure
        instance.cleanup!
      end
    end
  end
end

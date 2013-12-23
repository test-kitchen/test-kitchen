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

require 'thor/actions'

module Kitchen

  module Command

    # Base class for CLI commands.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Base

      protected

      attr_reader :args, :options, :help, :config, :shell

      include Logging
      include ::Thor::Actions

      def initialize(cmd_args, cmd_options, options = {})
        @args = cmd_args
        @options = cmd_options
        @help = options.fetch(:help, lambda { "No help provided" })
        @config = options.fetch(:config)
        @shell = options.fetch(:shell)
      end

      def die(msg)
        error "\n#{msg}\n\n"
        help.call
        exit 1
      end

      def get_all_instances
        result = @config.instances

        if result.empty?
          die "No instances defined"
        else
          result
        end
      end

      def get_filtered_instances(regexp)
        result = begin
          @config.instances.get(regexp) ||
            @config.instances.get_all(/#{regexp}/)
        rescue RegexpError => e
          die "Invalid Ruby regular expression, " +
            "you may need to single quote the argument. " +
            "Please try again or consult http://rubular.com/ (#{e.message})"
        end
        result = Array(result)

        if result.empty?
          die "No instances for regex `#{regexp}', try running `kitchen list'"
        else
          result
        end
      end

      def logger
        Kitchen.logger
      end

      def parse_subcommand(arg = nil)
        arg == "all" ? get_all_instances : get_filtered_instances(arg)
      end
    end

    # class Base < ::Thor

    #   protected

    #   include Common
    # end

    # class BaseGroup < ::Thor::Group

    #   protected

    #   include Common

    #   def self.banner
    #     "#{basename} #{usage}"
    #   end

    #   def self.usage(string = nil)
    #     string.nil? ? @usage : @usage = string
    #   end
    # end
  end
end

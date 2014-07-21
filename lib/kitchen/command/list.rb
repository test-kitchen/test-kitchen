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

require "kitchen/command"

module Kitchen

  module Command

    # Command to list one or more instances.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class List < Kitchen::Command::Base

      # Invoke the command.
      def call
        result = parse_subcommand(args.first)
        if options[:debug]
          die "The --debug flag on the list subcommand is deprecated, " \
            "please use `kitchen diagnose'."
        elsif options[:bare]
          puts Array(result).map { |i| i.name }.join("\n")
        else
          list_table(result)
        end
      end

      private

      # Add a trailing ansi color escape code to line up columns of colored
      # output.
      #
      # @param string [String] a string
      # @return [String]
      # @api private
      def color_pad(string)
        string + colorize("", :white)
      end

      # Generate the display rows for an instance.
      #
      # @param instance [Instance] an instance
      # @return [Array<String>]
      # @api private
      def display_instance(instance)
        [
          color_pad(instance.name),
          color_pad(instance.driver.name),
          color_pad(instance.provisioner.name),
          format_last_action(instance.last_action)
        ]
      end

      # Format and color the given last action.
      #
      # @param [String] the last action
      # @return [String] formated last action
      # @api private
      def format_last_action(last_action)
        case last_action
        when "create" then colorize("Created", :cyan)
        when "converge" then colorize("Converged", :magenta)
        when "setup" then colorize("Set Up", :blue)
        when "verify" then colorize("Verified", :yellow)
        when nil then colorize("<Not Created>", :red)
        else colorize("<Unknown>", :white)
        end
      end

      # Constructs a list display table and output it to the screen.
      #
      # @param result [Array<Instance>] an array of instances
      # @api private
      def list_table(result)
        table = [
          [
            colorize("Instance", :green), colorize("Driver", :green),
            colorize("Provisioner", :green), colorize("Last Action", :green)
          ]
        ]
        table += Array(result).map { |i| display_instance(i) }
        print_table(table)
      end

      # Outputs a formatted display table.
      #
      # @api private
      def print_table(*args)
        shell.print_table(*args)
      end

      # Colorize a string.
      #
      # @return [String] a colorized string
      # @api private
      def colorize(*args)
        shell.set_color(*args)
      end
    end
  end
end

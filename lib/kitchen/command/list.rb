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

require 'kitchen/command'

module Kitchen

  module Command

    # Command to list one or more instances.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class List < Kitchen::Command::Base

      def call
        result = parse_subcommand(args.first)
        if options[:debug]
          die "The --debug flag on the list subcommand is deprecated, " +
            "please use `kitchen diagnose'."
        elsif options[:bare]
          puts Array(result).map { |i| i.name }.join("\n")
        else
          list_table(result)
        end
      end

      private

      def color_pad(string)
        string + set_color("", :white)
      end

      def display_instance(instance)
        [
          color_pad(instance.name),
          color_pad(instance.driver.name),
          color_pad(instance.provisioner.name),
          format_last_action(instance.last_action)
        ]
      end

      def format_last_action(last_action)
        case last_action
        when 'create' then set_color("Created", :cyan)
        when 'converge' then set_color("Converged", :magenta)
        when 'setup' then set_color("Set Up", :blue)
        when 'verify' then set_color("Verified", :yellow)
        when nil then set_color("<Not Created>", :red)
        else set_color("<Unknown>", :white)
        end
      end

      def list_table(result)
        table = [
          [set_color("Instance", :green), set_color("Driver", :green),
            set_color("Provisioner", :green), set_color("Last Action", :green)]
        ]
        table += Array(result).map { |i| display_instance(i) }
        print_table(table)
      end

      def print_table(*args)
        shell.print_table(*args)
      end

      def set_color(*args)
        shell.set_color(*args)
      end
    end
  end
end

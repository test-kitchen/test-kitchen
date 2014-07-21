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

require "benchmark"

module Kitchen

  module Command

    # Command to test one or more instances.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Test < Kitchen::Command::Base

      include RunAction

      # Invoke the command.
      def call
        if !%w[passing always never].include?(options[:destroy])
          raise ArgumentError, "Destroy mode must be passing, always, or never."
        end

        banner "Starting Kitchen (v#{Kitchen::VERSION})"
        elapsed = Benchmark.measure do
          destroy_mode = options[:destroy].to_sym
          results = parse_subcommand(args.join("|"))

          run_action(:test, results, destroy_mode)
        end
        banner "Kitchen is finished. #{Util.duration(elapsed.real)}"
      end
    end
  end
end

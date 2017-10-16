# -*- encoding: utf-8 -*-
#
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
    # Check for common system or configuration problems.
    #
    class Doctor < Kitchen::Command::Base
      # Invoke the command.
      def call
        results = parse_subcommand(args.first)
        if results.empty?
          error("No instances configured, cannot check configuration. Please check your .kitchen.yml and confirm it has platform and suites sections.")
          exit(1)
        end
        # By default only doctor the first instance to avoid output spam.
        results = [results.first] unless options[:all]
        failed = results.any? do |instance|
          debug "Doctor on #{instance.name}."
          instance.doctor_action
        end
        exit(1) if failed
      end
    end
  end
end

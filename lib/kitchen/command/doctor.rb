#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../command"

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
        # Doctor every instance before deciding the outcome. #any? would
        # stop at the first instance reporting a problem and skip the rest.
        failed = results.map do |instance|
          debug "Doctor on #{instance.name}."
          instance.doctor_action
        end.any?
        exit(1) if failed
      end
    end
  end
end

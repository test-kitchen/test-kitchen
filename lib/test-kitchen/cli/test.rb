#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'test-kitchen/cli'
require 'test-kitchen/runner'

module TestKitchen
  module CLI
    class Kitchen
      class Test < Kitchen

        banner "kitchen test (options)"

        def run
          warn_for_non_buildable_platforms(env.platform_names)
          env.project.each_build(env.platform_names,
                             config[:configuration]) do |platform,configuration|
            runner = TestKitchen::Runner.for_platform(env,
              {:platform => platform, :configuration => configuration})
            runner.preflight_check
            begin
              runner.provision
              runner.test
            rescue
              raise
            ensure
              runner.destroy if config[:teardown]
            end
          end
        end

        private

        def warn_for_non_buildable_platforms(platform_names)
          if env.project.respond_to?(:non_buildable_platforms)
            env.project.non_buildable_platforms(platform_names).each do |platform|
              env.ui.info("Cookbook metadata specifies an unrecognized platform that will not be tested: #{platform}", :red)
            end
          end
        end

      end
    end
  end
end

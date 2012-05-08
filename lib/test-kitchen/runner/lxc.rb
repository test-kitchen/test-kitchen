#
# Author:: Andrew Crump (<andrew@kotirisoftware.com>)
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

module TestKitchen
  module Runner
    class LXC < Base

      NATTY = 'ubuntu-11.04'
      LXC_HOST = NATTY

      attr_reader :options
      attr_writer :nested_runner

      def initialize(env, options={})
        super
        raise_unless_host_box_available
        @env, @options = env, options
      end

      def nested_runner
        @nested_runner ||=
          Runner.targets['vagrant'].new(@env, @options).tap do |vagrant|
            vagrant.platform = NATTY
          end
      end

      def provision
        nested_runner.provision
        nested_runner.with_target_vms(LXC_HOST) do |vm|
          recipe_name = "#{env.project.name}_test::"
          recipe_name += env.project.name == configuration.name ?
            'default' : configuration.name
          nested_runner.execute_remote_command vm,
            "sudo test-kitchen-lxc provision '#{platform}' '#{recipe_name}'",
            "Provisioning Linux Container: #{platform} [#{configuration.name}]"
        end
      end

      def run_list
        ['test-kitchen::lxc']
      end

      def status
        raise NotImplementedError, "Not implemented"
      end

      def destroy
        nested_runner.with_target_vms(LXC_HOST) do |vm|
          nested_runner.execute_remote_command vm,
            "sudo test-kitchen-lxc destroy '#{platform}'",
            "Destroying Linux Container: #{platform} [#{configuration.name}]"
        end
        # TODO: Need to collect the nested VM
        #nested_runner.destroy
      end

      def ssh
        # TODO: SSH to the correct host
        nested_runner.ssh
      end

      def execute_remote_command(node, command, message=nil)
        nested_runner.with_target_vms(LXC_HOST) do |vm|
          nested_runner.execute_remote_command(vm, "sudo test-kitchen-lxc run '#{node}' '#{command}'", message)
        end
      end

      private

      def raise_unless_host_box_available
        distro_name, distro_version = NATTY.split('-')
        unless env.platforms[distro_name] and env.platforms[distro_name].versions[distro_version]
          raise ArgumentError, "LXC host box '#{NATTY}' is not available"
        end
      end

    end
  end
end

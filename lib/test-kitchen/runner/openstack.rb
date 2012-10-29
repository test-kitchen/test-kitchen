#
# Author:: Steven Danna (<steve@opscode.com>)
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

require 'fog'
require 'test-kitchen/runner/openstack/environment'

module TestKitchen
  module Runner
    class Openstack < Base


      # @vm: The TestKitchen::Platform::Version object
      #
      # @platform: From the parent constructor, contains the full name
      # of the relevant platform if we were created by #for_platform

      attr_accessor :vm

      def initialize(env, options={})
        super

        if @platform
          @vm = env.all_platforms[@platform]
        end

        @os_env = TestKitchen::Environment::Openstack.new()
      end

      def create
        env.ui.msg "[#{platform}] Provisioning guest on Openstack", :green
        @os_env.create_server(@platform,
                              { :instance_name => (vm.instance_name || "cookbook-tester-#{platform}"),
                                :image_id => vm.image_id,
                                :flavor_id => vm.flavor_id,
                                :keyname => vm.keyname,
                                :ssh_key => vm.ssh_key,
                                :ssh_user => vm.ssh_user})

      end

      def converge
        install_chef if vm.install_chef
        move_repo
        move_cookbooks
        run_chef_solo
      end

      # status and destroy are expected to operate on all
      # vm's in an environment
      def status
        env.all_platforms.each do |name, ver|
          env.ui.msg "#{name}\t#{@os_env.status(name)}"
        end
      end

      def destroy
        env.all_platforms.each do |name, platform|
          env.ui.msg "[#{name}] Terminating openstack server", :yellow
          @os_env.destroy name
        end
      end

      def execute_remote_command(platform_name, command, message=nil)
        env.ui.msg("[#{platform_name}] #{message}", :green) if message
        results = @os_env.ssh(platform_name).run(command) do |data|
          stdout, stderr = data.map {|s| s.rstrip}
          stdout.lines.each do |line|
            env.ui.msg "[#{platform_name}] #{line}", :green
          end
          stderr.lines.each do |line|
            env.ui.msg "[#{platform_name}] #{line}", :red
          end
        end
        if results.first.status != 0
          msg = message || "Remote command"
          env.ui.msg "[#{platform_name}] #{msg} failed!", :red
        end
      end

      private

      def install_chef(name=platform)
        execute_remote_command(name, vm.install_chef_cmd, "Installing Chef")
      end

      def run_chef_solo(name=platform)
        execute_remote_command(name, "echo '#{json_for_node}' > node.json",
                               "Creating node configuration JSON")
        execute_remote_command(name, "echo 'cookbook_path [ \"#{remote_cookbook_dir}\" ]' > solo.rb",
                               "Creating chef-solo configuration")
        execute_remote_command(name, "sudo chef-solo -j node.json -c solo.rb",
                               "Running chef-solo on host")
      end

      def move_cookbooks(name=platform)
        env.ui.msg("[#{name}] Moving cookbooks via SCP", :green)
        @os_env.scp(name).upload(File.join(env.tmp_path, "cookbooks"),
                                 remote_cookbook_dir, :recursive => true)
      end

      def move_repo(name=platform)
        env.ui.msg("[#{name}] Moving repo via SCP", :green)
        execute_remote_command(name, "sudo mkdir -p #{remote_root_dir}")
        execute_remote_command(name, "sudo chown #{vm.ssh_user} #{remote_root_dir}")
        @os_env.scp(name).upload(File.join(env.tmp_path, "cookbook_under_test"),
                                 configuration.guest_source_root,
                                 {:recursive => true})
      end

      def json_for_node
        {
          'test-kitchen' => {
            'project' => configuration.to_hash.merge('source_root' => configuration.guest_source_root,
                                                     'test_root' => configuration.guest_test_root)},
          'run_list' => run_list
        }.to_json
      end

      def run_list
        configuration.run_list + [test_recipe_name]
      end

      def remote_root_dir
        File.dirname(configuration.guest_source_root)
      end

      def remote_cookbook_dir
        File.join(remote_root_dir, 'cookbooks')
      end
    end
  end
end

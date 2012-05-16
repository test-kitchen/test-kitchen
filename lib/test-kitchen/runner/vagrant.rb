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

require 'vagrant'

module TestKitchen
  module Runner
    class Vagrant < Base

      def initialize(env, options={})
        super
        @env, @options = env, options
      end

      def provision
        super
        vagrant_env.cli(vagrant_cli_argv('up'))
      end

      def status
        vagrant_env.cli(vagrant_cli_argv('status'))
      end

      def destroy
        vagrant_env.cli(vagrant_cli_argv(['destroy', '--force']))
      end

      def ssh
        vagrant_env.cli(vagrant_cli_argv('ssh'))
      end

      def execute_remote_command(vm, command, message=nil)
        vm = vagrant_env.vms[vm.to_sym] unless vm.kind_of?(::Vagrant::VM)
        vm.ui.info(message, :color => :yellow) if message
        vm.channel.execute(command, :error_check => false) do |type, data|
          next if data =~ /stdin: is not a tty/
          if [:stderr, :stdout].include?(type)
            # Output the data with the proper color based on the stream.
            color = type == :stdout ? :green : :red
            vm.ui.info(data, :color => color, :prefix => false, :new_line => false)
          end
        end
      end

      private

      def vagrant_env
        @vagrant_env ||= begin
          env.create_tmp_file('Vagrantfile',
            IO.read(TestKitchen.source_root.join('config', 'Vagrantfile')))

          options = {
            :ui_class => ::Vagrant::UI::Colored,
            :cwd => env.tmp_path
          }

          env = ::Vagrant::Environment.new(options)
          env.load!
          env
        end
      end

      def vagrant_cli_argv(command)
        argv = Array(command)
        argv << platform if platform
        argv
      end

    end
  end
end

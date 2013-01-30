# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, Fletcher Nichol
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

require 'net/ssh'
require 'socket'

module Kitchen

  module Driver

    # Base class for a driver that uses SSH to communication with an instance.
    # A subclass must implement the following methods:
    # * #create(state)
    # * #destroy(state)
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class SSHBase < Base

      def create(state)
        raise ClientError, "#{self.class}#create must be implemented"
      end

      def converge(state)
        ssh_args = build_ssh_args(state)

        install_omnibus(ssh_args) if config[:require_chef_omnibus]
        prepare_chef_home(ssh_args)
        upload_chef_data(ssh_args)
        run_chef_solo(ssh_args)
      end

      def setup(state)
        ssh_args = build_ssh_args(state)

        if instance.jr.setup_cmd
          ssh(ssh_args, instance.jr.setup_cmd)
        end
      end

      def verify(state)
        ssh_args = build_ssh_args(state)

        if instance.jr.run_cmd
          ssh(ssh_args, instance.jr.sync_cmd)
          ssh(ssh_args, instance.jr.run_cmd)
        end
      end

      def destroy(state)
        raise ClientError, "#{self.class}#destroy must be implemented"
      end

      def login_command(state)
        args  = %W{ -o UserKnownHostsFile=/dev/null }
        args += %W{ -o StrictHostKeyChecking=no }
        args += %W{ -i #{config[:ssh_key]}} if config[:ssh_key]
        args += %W{ #{config[:username]}@#{state[:hostname]}}

        ["ssh", *args]
      end

      protected

      def build_ssh_args(state)
        opts = Hash.new
        opts[:user_known_hosts_file] = "/dev/null"
        opts[:paranoid] = false
        opts[:password] = config[:password] if config[:password]
        opts[:keys] = Array(config[:ssh_key]) if config[:ssh_key]

        [state[:hostname], config[:username], opts]
      end

      def chef_home
        "/tmp/kitchen-chef-solo".freeze
      end

      def install_omnibus(ssh_args)
        flag = config[:require_chef_omnibus]
        version = flag.is_a?(String) ? "-s -- -v #{flag}" : ""

        ssh(ssh_args, <<-INSTALL.gsub(/^ {10}/, ''))
          if [ ! -d "/opt/chef" ] ; then
            curl -sSL https://www.opscode.com/chef/install.sh \
              | sudo bash #{version}
          fi
        INSTALL
      end

      def prepare_chef_home(ssh_args)
        ssh(ssh_args, "sudo rm -rf #{chef_home} && mkdir -p #{chef_home}/cache")
      end

      def upload_chef_data(ssh_args)
        Kitchen::ChefDataUploader.new(
          instance, ssh_args, config[:kitchen_root], chef_home
        ).upload
      end

      def run_chef_solo(ssh_args)
        ssh(ssh_args, <<-RUN_SOLO)
          sudo chef-solo -c #{chef_home}/solo.rb -j #{chef_home}/dna.json \
            --log_level #{Util.from_logger_level(logger.level)}
        RUN_SOLO
      end

      def ssh(ssh_args, cmd)
        debug("[SSH] #{ssh_args[1]}@#{ssh_args[0]} (#{cmd})")
        Net::SSH.start(*ssh_args) do |ssh|
          exit_code = ssh_exec_with_exit!(ssh, cmd)

          if exit_code != 0
            shorter_cmd = cmd.squeeze(" ").strip
            raise ActionFailed,
              "SSH exited (#{exit_code}) for command: [#{shorter_cmd}]"
          end
        end
      rescue Net::SSH::Exception => ex
        raise ActionFailed, ex.message
      end

      def ssh_exec_with_exit!(ssh, cmd)
        exit_code = nil
        ssh.open_channel do |channel|

          channel.request_pty

          channel.exec(cmd) do |ch, success|

            channel.on_data do |ch, data|
              logger << data
            end

            channel.on_extended_data do |ch, type, data|
              logger << data
            end

            channel.on_request("exit-status") do |ch, data|
              exit_code = data.read_long
            end
          end
        end
        ssh.loop
        exit_code
      end

      def wait_for_sshd(hostname)
        logger << "." until test_ssh(hostname)
      end

      def test_ssh(hostname)
        socket = TCPSocket.new(hostname, config[:port])
        IO.select([socket], nil, nil, 5)
      rescue SocketError, Errno::ECONNREFUSED,
        Errno::EHOSTUNREACH, Errno::ENETUNREACH, IOError
        sleep 2
        false
      rescue Errno::EPERM, Errno::ETIMEDOUT
        false
      ensure
        socket && socket.close
      end
    end
  end
end

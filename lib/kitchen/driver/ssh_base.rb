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

      default_config :sudo, true
      default_config :port, 22

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

        if busser_setup_cmd
          ssh(ssh_args, busser_setup_cmd)
        end
      end

      def verify(state)
        ssh_args = build_ssh_args(state)

        if busser_run_cmd
          ssh(ssh_args, busser_sync_cmd)
          ssh(ssh_args, busser_run_cmd)
        end
      end

      def destroy(state)
        raise ClientError, "#{self.class}#destroy must be implemented"
      end

      def login_command(state)
        combined = config.merge(state)

        args  = %W{ -o UserKnownHostsFile=/dev/null }
        args += %W{ -o StrictHostKeyChecking=no }
        args += %W{ -o LogLevel=#{logger.debug? ? "VERBOSE" : "ERROR"} }
        args += %W{ -i #{combined[:ssh_key]}} if combined[:ssh_key]
        args += %W{ -p #{combined[:port]}} if combined[:port]
        args += %W{ #{combined[:username]}@#{combined[:hostname]}}

        Driver::LoginCommand.new(["ssh", *args])
      end

      protected

      def build_ssh_args(state)
        combined = config.merge(state)

        opts = Hash.new
        opts[:user_known_hosts_file] = "/dev/null"
        opts[:paranoid] = false
        opts[:password] = combined[:password] if combined[:password]
        opts[:port] = combined[:port] if combined[:port]
        opts[:keys] = Array(combined[:ssh_key]) if combined[:ssh_key]

        [combined[:hostname], combined[:username], opts]
      end

      def chef_home
        "/tmp/kitchen-chef-solo".freeze
      end

      def install_omnibus(ssh_args)
        url = "https://www.opscode.com/chef/install.sh"
        flag = config[:require_chef_omnibus]
        version = if flag.is_a?(String) && flag != "latest"
          "-s -- -v #{flag.downcase}"
        else
          ""
        end

        ssh(ssh_args, <<-INSTALL.gsub(/^ {10}/, ''))
          should_update_chef() {
            case "#{flag}" in
              true|$(chef-solo -v | cut -d " " -f 2)) return 1 ;;
              latest|*) return 0 ;;
            esac
          }

          if [ ! -d "/opt/chef" ] || should_update_chef ; then
            echo "-----> Installing Chef Omnibus (#{flag})"
            if command -v wget >/dev/null ; then
              wget #{url} -O - | #{cmd('bash')} #{version}
            elif command -v curl >/dev/null ; then
              curl -sSL #{url} | #{cmd('bash')} #{version}
            else
              echo ">>>>>> Neither wget nor curl found on this instance."
              exit 1
            fi
          fi
        INSTALL
      end

      def prepare_chef_home(ssh_args)
        ssh(ssh_args, "#{cmd('rm')} -rf #{chef_home} && mkdir -p #{chef_home}/cache")
      end

      def upload_chef_data(ssh_args)
        Kitchen::ChefDataUploader.new(
          instance, ssh_args, config[:kitchen_root], chef_home
        ).upload
      end

      def run_chef_solo(ssh_args)
        ssh(ssh_args, <<-RUN_SOLO)
          #{cmd('chef-solo')} -c #{chef_home}/solo.rb -j #{chef_home}/dna.json \
            --log_level #{Util.from_logger_level(logger.level)}
        RUN_SOLO
      end

      def ssh(ssh_args, cmd)
        env = "env"
        if config[:http_proxy]
          env << " http_proxy=#{config[:http_proxy]}"
        end
        if config[:https_proxy]
          env << " https_proxy=#{config[:https_proxy]}"
        end
        if env != "env"
          cmd = "#{env} #{cmd}"
        end

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

      def wait_for_sshd(ssh_args)
        logger << "." until test_ssh(ssh_args)
      end

      def test_ssh(ssh_args)
        socket = TCPSocket.new(ssh_args[0], ssh_args[2][:port])
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

      def cmd(script)
        config[:sudo] ? "sudo -E #{script}" : script
      end
    end
  end
end

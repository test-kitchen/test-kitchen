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
        provisioner = instance.provisioner
        provisioner.create_sandbox
        sandbox_dirs = Dir.glob("#{provisioner.sandbox_path}/*")

        Kitchen::SSH.new(*build_ssh_args(state)) do |conn|
          run_remote(provisioner.install_command, conn)
          run_remote(provisioner.init_command, conn)
          transfer_path(sandbox_dirs, provisioner[:root_path], conn)
          run_remote(provisioner.prepare_command, conn)
          run_remote(provisioner.run_command, conn)
        end
      ensure
        provisioner && provisioner.cleanup_sandbox
      end

      def setup(state)
        Kitchen::SSH.new(*build_ssh_args(state)) do |conn|
          run_remote(busser_setup_cmd, conn)
        end
      end

      def verify(state)
        Kitchen::SSH.new(*build_ssh_args(state)) do |conn|
          run_remote(busser_sync_cmd, conn)
          run_remote(busser_run_cmd, conn)
        end
      end

      def destroy(state)
        raise ClientError, "#{self.class}#destroy must be implemented"
      end

      def login_command(state)
        SSH.new(*build_ssh_args(state)).login_command
      end

      def ssh(ssh_args, command)
        Kitchen::SSH.new(*ssh_args) do |conn|
          run_remote(command, conn)
        end
      end

      protected

      def build_ssh_args(state)
        combined = config.to_hash.merge(state)

        opts = Hash.new
        opts[:user_known_hosts_file] = "/dev/null"
        opts[:paranoid] = false
        opts[:keys_only] = true if combined[:ssh_key]
        opts[:password] = combined[:password] if combined[:password]
        opts[:forward_agent] = combined[:forward_agent] if combined.key? :forward_agent
        opts[:port] = combined[:port] if combined[:port]
        opts[:keys] = Array(combined[:ssh_key]) if combined[:ssh_key]
        opts[:logger] = logger

        [combined[:hostname], combined[:username], opts]
      end

      def env
        [:http_proxy, :https_proxy].reduce(Hash.new) do |env, key|
          env[key] = config[key] if config[key]
          env
        end
      end

      def run_remote(command, connection)
        return if command.nil?

        connection.exec(command, env)
      rescue SSHFailed, Net::SSH::Exception => ex
        raise ActionFailed, ex.message
      end

      def transfer_path(locals, remote, connection)
        return if locals.nil? || Array(locals).empty?

        info("Transfering files to #{instance.to_str}")
        locals.each { |local| connection.upload_path!(local, remote) }
        debug("Transfer complete")
      rescue SSHFailed, Net::SSH::Exception => ex
        raise ActionFailed, ex.message
      end

      def wait_for_sshd(hostname, username = nil, options = {})
        SSH.new(hostname, username, { :logger => logger }.merge(options)).wait
      end
    end
  end
end

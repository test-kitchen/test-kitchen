# -*- encoding: utf-8 -*-
#
# Author:: Salim Afiune (<salim@afiunemaya.com.mx>)
#
# Copyright (C) 2014, Salim Afiune
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

    # Base class for a driver that uses WinRM to communicate with an instance.
    # A subclass must implement the following methods:
    # * #create(state)
    # * #destroy(state)
    #
    # @author Salim Afiune <salim@afiunemaya.com.mx>
    class WinRMBase < Base

      default_config :sudo, false
      default_config :port, 5985

      def create(state) # rubocop:disable Lint/UnusedMethodArgument
        raise ClientError, "#{self.class}#create must be implemented"
      end

      def converge(state)
        provisioner = instance.provisioner

        # Override sudo config if NOT equals to default for Windows
        provisioner.sudo = config[:sudo] if provisioner[:sudo] != config[:sudo]

        provisioner.create_sandbox
        sandbox_dirs = Dir.glob("#{provisioner.sandbox_path}/*")
        Kitchen::WinRM.new(*build_winrm_args(state)) do |conn|
          run_remote(provisioner.install_command_posh, conn)
          run_remote(provisioner.init_command_posh, conn, false)
          transfer_path(sandbox_dirs, provisioner[:root_path], conn)
          run_remote(provisioner.prepare_command, conn)
          run_remote(provisioner.run_command, conn)
        end
      ensure
        provisioner && provisioner.cleanup_sandbox
      end

      # (see Base#setup)
      def setup(state)
        Kitchen::WinRM.new(*build_winrm_args(state)) do |conn|
          run_remote(busser.setup_cmd_posh, conn)
        end
      end

      # (see Base#verify)
      def verify(state)
        Kitchen::WinRM.new(*build_winrm_args(state)) do |conn|
          run_remote(busser.sync_cmd_posh, conn)
          run_remote(busser.run_cmd_posh, conn)
        end
      end

      def destroy(state) # rubocop:disable Lint/UnusedMethodArgument
        raise ClientError, "#{self.class}#destroy must be implemented"
      end

      def login_command(state)
        WinRM.new(*build_winrm_args(state)).login_command(vagrant_root)
      end

      def remote_command(state, command)
        Kitchen::WinRM.new(*build_winrm_args(state)) do |conn|
          run_remote(command, conn)
        end
      end

      def winrm(winrm_args, command)
        Kitchen::WinRM.new(*winrm_args) do |conn|
          run_remote(command, conn)
        end
      end

      protected

      def build_winrm_args(state)
        combined = config.to_hash.merge(state)

        opts = Hash.new
        opts[:port]           = combined[:port] if combined[:port]
        opts[:password]       = combined[:password] if combined[:password]
        opts[:forward_agent]  = combined[:forward_agent] if combined.key? :forward_agent
        opts[:logger]         = logger

        [combined[:hostname], combined[:username], opts]
      end

      def env_cmd(cmd)
        env = ""
        env << " $env:http_proxy=\"#{config[:http_proxy]}\";"   if config[:http_proxy]
        env << " $env:https_proxy=\"#{config[:https_proxy]}\";" if config[:https_proxy]

        env == "" ? cmd : "#{env} #{cmd}"
      end

      def run_remote(command, connection, stdout = true)
        return if command.nil?

        stdout ? connection.exec(env_cmd(command)) : connection.powershell(env_cmd(command))
      rescue WinRMFailed, WinRM::WinRMHTTPTransportError,
      WinRM::WinRMAuthorizationError, WinRM::WinRMWebServiceError => ex
        raise ActionFailed, ex.message
      end

      def transfer_path(locals, remote, connection)
        return if locals.nil? || Array(locals).empty?

        info("Transferring files to #{instance.to_str}")
        locals.each { |local| connection.upload!(local, remote) }
        debug("Transfer complete")
      rescue WinRMFailed, ::WinRM::WinRMHTTPTransportError,
      ::WinRM::WinRMAuthorizationError, ::WinRM::WinRMWebServiceError => ex
        raise ActionFailed, ex.message
      end

      def wait_for_winrm(hostname, username = nil, options = {})
        WinRM.new(hostname, username, { :logger => logger }.merge(options)).wait
      end
    end
  end
end

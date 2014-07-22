require 'kitchen/transport/base'

module Kitchen
  module Transport
    # Base class that defines the Transport interface
    class WinRM < Base
      # This class might be merged with Kitchen::WinRM class
      # But in order to preserve backwards compatibility we use it as is
      # for now.

      def initialize(state, driver)
        super(state, driver)

        @connection = Kitchen::WinRM.new(*build_winrm_args(state))
      end


      # TODO: Why do we have a stdout parameter in the method signature here?
      def run_remote(command, stdout=true)
        return if command.nil?

        stdout ? connection.exec(env_cmd(command)) : connection.powershell(env_cmd(command))
      rescue WinRMFailed, WinRM::WinRMHTTPTransportError,
        WinRM::WinRMAuthorizationError, WinRM::WinRMWebServiceError => ex
        raise ActionFailed, ex.message
      end

      def transfer_path(locals, remote)
        return if locals.nil? || Array(locals).empty?

        driver.info("Transferring files to #{driver.instance.to_str}")
        locals.each { |local| connection.upload!(local, remote) }
        driver.debug("Transfer complete")
      rescue WinRMFailed, ::WinRM::WinRMHTTPTransportError,
        ::WinRM::WinRMAuthorizationError, ::WinRM::WinRMWebServiceError => ex
        raise ActionFailed, ex.message
      end

      # Blocks until a TCP socket is available where a remote SSH server
      # should be listening.
      #
      # @param hostname [String] remote SSH server host
      # @param username [String] SSH username (default: `nil`)
      # @param options [Hash] configuration hash (default: `{}`)
      # @api private
      def wait_for_connection(hostname, username = nil, options = {})
        WinRM.new(hostname, username, { :logger => driver.logger }.merge(options)).wait
      end

      # TODO: Where is the vagrant_root coming from here?
      def login_command
        connection.login_command(vagrant_root)
      end

      # TODO: Add documentation
      def disconnect
        connection.shutdown
      end

      private

      def build_winrm_args(state)
        combined = driver.config.to_hash.merge(state)

        opts = Hash.new
        opts[:port]           = combined[:port] if combined[:port]
        opts[:password]       = combined[:password] if combined[:password]
        opts[:forward_agent]  = combined[:forward_agent] if combined.key? :forward_agent
        opts[:logger]         = driver.logger

        [combined[:hostname], combined[:username], opts]
      end

      def env_cmd(cmd)
        env = ""
        env << " $env:http_proxy=\"#{driver.config[:http_proxy]}\";"   if driver.config[:http_proxy]
        env << " $env:https_proxy=\"#{driver.config[:https_proxy]}\";" if driver.config[:https_proxy]

        env == "" ? cmd : "#{env} #{cmd}"
      end
    end
  end
end

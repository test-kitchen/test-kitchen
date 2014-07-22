require 'kitchen/transport/base'

module Kitchen
  module Transport
    # Base class that defines the Transport interface
    class SSH < Base
      # This class might be merged with Kitchen::SSH class
      # But in order to preserve backwards compatibility we use it as is
      # for now.

      def initialize(config, state, logger)
        super(config, state, logger)

        @connection = Kitchen::SSH.new(*build_ssh_args(state))
      end


      # Executes a remote command over SSH.
      #
      # @param command [String] remove command to run
      # @raise [ActionFailed] if an exception occurs
      # @api private
      def run_remote(command)
        return if command.nil?

        connection.exec(env_cmd(command))
      rescue SSHFailed, Net::SSH::Exception => ex
        raise ActionFailed, ex.message
      end

      # Transfers one or more local paths over SSH.
      #
      # @param locals [Array<String>] array of local paths
      # @param remote [String] remote destination path
      # @raise [ActionFailed] if an exception occurs
      # @api private
      def transfer_path(locals, remote)
        return if locals.nil? || Array(locals).empty?

        info("Transferring files to #{instance.to_str}")
        locals.each { |local| connection.upload_path!(local, remote) }
        debug("Transfer complete")
      rescue SSHFailed, Net::SSH::Exception => ex
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
        SSH.new(hostname, username, { :logger => logger }.merge(options)).wait
      end

      # TODO: Add documentation
      def login_command
        connection.login_command
      end

      # TODO: Add documentation
      def disconnect
        connection.shutdown
      end

      private

      # Builds arguments for constructing a `Kitchen::SSH` instance.
      #
      # @param state [Hash] state hash
      # @return [Array] SSH constructor arguments
      # @api private
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

      # Adds http and https proxy environment variables to a command, if set
      # in configuration data.
      #
      # @param cmd [String] command string
      # @return [String] command string
      # @api private
      def env_cmd(cmd)
        env = "env"
        env << " http_proxy=#{config[:http_proxy]}"   if config[:http_proxy]
        env << " https_proxy=#{config[:https_proxy]}" if config[:https_proxy]

        env == "env" ? cmd : "#{env} #{cmd}"
      end
    end
  end
end

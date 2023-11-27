#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2014, Fletcher Nichol
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

require_relative "../../kitchen"
require_relative "../util"

require "fileutils" unless defined?(FileUtils)
require "net/ssh" unless defined?(Net::SSH)
require "net/ssh/gateway"
require "net/ssh/proxy/http"
require "net/scp"
require "timeout" unless defined?(Timeout)
require "benchmark" unless defined?(Benchmark)

module Kitchen
  module Transport
    # Wrapped exception for any internally raised SSH-related errors.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class SshFailed < TransportFailed; end

    # A Transport which uses the SSH protocol to execute commands and transfer
    # files.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Ssh < Kitchen::Transport::Base
      kitchen_transport_api_version 1

      plugin_version Kitchen::VERSION

      default_config :port, 22
      default_config :username, "root"
      default_config :keepalive, true
      default_config :keepalive_interval, 60
      default_config :keepalive_maxcount, 3
      # needs to be one less than the configured sshd_config MaxSessions
      default_config :max_ssh_sessions, 9
      default_config :connection_timeout, 15
      default_config :connection_retries, 5
      default_config :connection_retry_sleep, 1
      default_config :max_wait_until_ready, 600

      default_config :ssh_gateway, nil
      default_config :ssh_gateway_port, 22
      default_config :ssh_gateway_username, nil

      default_config :ssh_http_proxy, nil
      default_config :ssh_http_proxy_port, nil
      default_config :ssh_http_proxy_user, nil
      default_config :ssh_http_proxy_password, nil

      default_config :ssh_key, nil
      expand_path_for :ssh_key

      # compression disabled by default for speed
      default_config :compression, false
      required_config :compression

      default_config :compression_level do |transport|
        transport[:compression] == false ? 0 : 6
      end

      def finalize_config!(instance)
        super

        # zlib was never a valid value and breaks in net-ssh >= 2.10
        # TODO: remove these backwards compatiable casts in 2.0
        case config[:compression]
        when "zlib"
          config[:compression] = "zlib@openssh.com"
        when "none"
          config[:compression] = false
        end

        self
      end

      # (see Base#connection)
      def connection(state, &block)
        options = connection_options(config.to_hash.merge(state))

        if @connection && @connection_options == options
          reuse_connection(&block)
        else
          create_new_connection(options, &block)
        end
      end

      # (see Base#cleanup!)
      def cleanup!
        if @connection
          string_to_mask = "[SSH] shutting previous connection #{@connection}"
          masked_string = Util.mask_values(string_to_mask, %w{password ssh_http_proxy_password})
          logger.debug(masked_string)
          @connection.close
          @connection = @connection_options = nil
        end
      end

      # A Connection instance can be generated and re-generated, given new
      # connection details such as connection port, hostname, credentials, etc.
      # This object is responsible for carrying out the actions on the remote
      # host such as executing commands, transferring files, etc.
      #
      # @author Fletcher Nichol <fnichol@nichol.ca>
      class Connection < Kitchen::Transport::Base::Connection
        # (see Base::Connection#initialize)
        def initialize(config = {})
          super(config)
          @session = nil
        end

        # (see Base::Connection#close)
        def close
          return if @session.nil?

          string_to_mask = "[SSH] closing connection to #{self}"
          masked_string = Util.mask_values(string_to_mask, %w{password ssh_http_proxy_password})
          logger.debug(masked_string)
          session.close
        ensure
          @session = nil
        end

        # (see Base::Connection#execute)
        def execute(command)
          return if command.nil?

          string_to_mask = "[SSH] #{self} (#{command})"
          masked_string = Util.mask_values(string_to_mask, %w{password ssh_http_proxy_password})
          logger.debug(masked_string)
          exit_code = execute_with_exit_code(command)

          if exit_code != 0
            raise Transport::SshFailed.new(
              "SSH exited (#{exit_code}) for command: [#{command}]",
              exit_code
            )
          end
        rescue Net::SSH::Exception => ex
          raise SshFailed, "SSH command failed (#{ex.message})"
        end

        # (see Base::Connection#login_command)
        def login_command
          args  = %w{ -o UserKnownHostsFile=/dev/null }
          args += %w{ -o StrictHostKeyChecking=no }
          args += %w{ -o IdentitiesOnly=yes } if options[:keys]
          args += %W{ -o LogLevel=#{logger.debug? ? "VERBOSE" : "ERROR"} }
          if options.key?(:forward_agent)
            args += %W{ -o ForwardAgent=#{options[:forward_agent] ? "yes" : "no"} }
          end
          if ssh_gateway
            gateway_command = "ssh -q #{ssh_gateway_username}@#{ssh_gateway} nc #{hostname} #{port}"
            args += %W{ -o ProxyCommand=#{gateway_command} -p #{ssh_gateway_port} }
          end
          Array(options[:keys]).each { |ssh_key| args += %W{ -i #{ssh_key} } }
          args += %W{ -p #{port} }
          args += %W{ #{username}@#{hostname} }

          LoginCommand.new("ssh", args)
        end

        # (see Base::Connection#upload)
        def upload(locals, remote)
          logger.debug("TIMING: scp async upload (Kitchen::Transport::Ssh)")
          elapsed = Benchmark.measure do
            waits = []
            Array(locals).map do |local|
              opts = File.directory?(local) ? { recursive: true } : {}

              waits.push(
                session.scp.upload(local, remote, opts) do |_ch, name, sent, total|
                  logger.debug("Async Uploaded #{name} (#{total} bytes)") if sent == total
                end
              )
              waits.shift.wait while waits.length >= max_ssh_sessions
            end
            waits.each(&:wait)
          end
          delta = Util.duration(elapsed.real)
          logger.debug("TIMING: scp async upload (Kitchen::Transport::Ssh) took #{delta}")
        rescue Net::SSH::Exception => ex
          raise SshFailed, "SCP upload failed (#{ex.message})"
        end

        # (see Base::Connection#download)
        def download(remotes, local)
          # ensure the parent dir of the local target exists
          FileUtils.mkdir_p(File.dirname(local))

          Array(remotes).each do |file|
            logger.debug("Attempting to download '#{file}' as file")
            session.scp.download!(file, local)
          rescue Net::SCP::Error
            begin
              logger.debug("Attempting to download '#{file}' as directory")
              session.scp.download!(file, local, recursive: true)
            rescue Net::SCP::Error
              logger.warn(
                "SCP download failed for file or directory '#{file}', perhaps it does not exist?"
              )
            end
          end
        rescue Net::SSH::Exception => ex
          raise SshFailed, "SCP download failed (#{ex.message})"
        end

        # (see Base::Connection#wait_until_ready)
        def wait_until_ready
          delay = 3
          session(
            retries: max_wait_until_ready / delay,
            delay:,
            message: "Waiting for SSH service on #{hostname}:#{port}, " \
              "retrying in #{delay} seconds"
          )
          execute(PING_COMMAND.dup)
        end

        private

        PING_COMMAND = "echo '[SSH] Established'".freeze

        RESCUE_EXCEPTIONS_ON_ESTABLISH = [
          Errno::EACCES, Errno::EALREADY, Errno::EADDRINUSE, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
          Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EHOSTUNREACH, Errno::EPIPE,
          Net::SSH::Disconnect, Net::SSH::AuthenticationFailed, Net::SSH::ConnectionTimeout,
          Net::SSH::Proxy::ConnectError, Timeout::Error
        ].freeze

        # @return [Integer] cap on number of parallel ssh sessions we can use
        # @api private
        attr_reader :max_ssh_sessions

        # @return [Integer] how many times to retry when failing to execute
        #   a command or transfer files
        # @api private
        attr_reader :connection_retries

        # @return [Float] how many seconds to wait before attempting a retry
        #   when failing to execute a command or transfer files
        # @api private
        attr_reader :connection_retry_sleep

        # @return [String] the hostname or IP address of the remote SSH host
        # @api private
        attr_reader :hostname

        # @return [Integer] how many times to retry when invoking
        #   `#wait_until_ready` before failing
        # @api private
        attr_reader :max_wait_until_ready

        # @return [String] the username to use when connecting to the remote
        #   SSH host
        # @api private
        attr_reader :username

        # @return [Integer] the TCP port number to use when connecting to the
        #   remote SSH host
        # @api private
        attr_reader :port

        # @return [String] The ssh gateway to use when connecting to the
        #   remote SSH host
        # @api private
        attr_reader :ssh_gateway

        # @return [String] The username to use when using an ssh gateway
        # @api private
        attr_reader :ssh_gateway_username

        # @return [Integer] The port to use when using an ssh gateway
        # @api private
        attr_reader :ssh_gateway_port

        # @return [String] The kitchen ssh proxy to use when connecting to the
        #   remote SSH host via http proxy
        # @api private
        attr_reader :ssh_http_proxy

        # @return [Integer] The port to use when using an kitchen ssh proxy
        #   remote SSH host via http proxy
        # @api private
        attr_reader :ssh_http_proxy_port

        # @return [String] The username to use when using an kitchen ssh proxy
        #   remote SSH host via http proxy
        # @api private
        attr_reader :ssh_http_proxy_user

        # @return [String] The password to use when using an kitchen ssh proxy
        #   remote SSH host via http proxy
        # @api private
        attr_reader :ssh_http_proxy_password

        # Establish an SSH session on the remote host using a gateway host.
        #
        # @param opts [Hash] retry options
        # @option opts [Integer] :retries the number of times to retry before
        #   failing
        # @option opts [Float] :delay the number of seconds to wait until
        #   attempting a retry
        # @option opts [String] :message an optional message to be logged on
        #   debug (overriding the default) when a rescuable exception is raised
        # @return [Net::SSH::Connection::Session] the SSH connection session
        # @api private
        def establish_connection_via_gateway(opts)
          retry_connection(opts) do
            gateway_options = options.merge(port: ssh_gateway_port)
            Net::SSH::Gateway.new(ssh_gateway,
              ssh_gateway_username, gateway_options).ssh(hostname, username, options)
          end
        end

        # Establish an SSH session on the remote host.
        #
        # @param opts [Hash] retry options
        # @option opts [Integer] :retries the number of times to retry before
        #   failing
        # @option opts [Float] :delay the number of seconds to wait until
        #   attempting a retry
        # @option opts [String] :message an optional message to be logged on
        #   debug (overriding the default) when a rescuable exception is raised
        # @return [Net::SSH::Connection::Session] the SSH connection session
        # @api private
        def establish_connection(opts)
          retry_connection(opts) do
            Net::SSH.start(hostname, username, options)
          end
        end

        # Connect to a host executing passed block and properly handling retries.
        #
        # @param opts [Hash] retry options
        # @option opts [Integer] :retries the number of times to retry before
        #   failing
        # @option opts [Float] :delay the number of seconds to wait until
        #   attempting a retry
        # @option opts [String] :message an optional message to be logged on
        #   debug (overriding the default) when a rescuable exception is raised
        # @return [Net::SSH::Connection::Session] the SSH connection session
        # @api private
        def retry_connection(opts)
          log_msg = "[SSH] opening connection to #{self}"
          log_msg += " via #{ssh_gateway_username}@#{ssh_gateway}:#{ssh_gateway_port}" if ssh_gateway
          masked_string = Util.mask_values(log_msg, %w{password ssh_http_proxy_password})

          logger.debug(masked_string)
          yield
        rescue *RESCUE_EXCEPTIONS_ON_ESTABLISH => e
          if (opts[:retries] -= 1) > 0
            message = if opts[:message]
                        logger.debug("[SSH] connection failed (#{e.inspect})")
                        opts[:message]
                      else
                        "[SSH] connection failed, retrying in #{opts[:delay]} seconds " \
                          "(#{e.inspect})"
                      end
            logger.info(message)
            sleep(opts[:delay])
            retry
          else
            logger.warn("[SSH] connection failed, terminating (#{e.inspect})")
            raise SshFailed, "SSH session could not be established"
          end
        end

        # Execute a remote command over SSH and return the command's exit code.
        #
        # @param command [String] command string to execute
        # @return [Integer] the exit code of the command
        # @api private
        def execute_with_exit_code(command)
          exit_code = nil
          session.open_channel do |channel|
            channel.request_pty

            channel.exec(command) do |_ch, _success|
              channel.on_data do |_ch, data|
                logger << data
              end

              channel.on_extended_data do |_ch, _type, data|
                logger << data
              end

              channel.on_request("exit-status") do |_ch, data|
                exit_code = data.read_long
              end
            end
          end
          session.loop
          exit_code
        end

        # (see Base::Connection#init_options)
        def init_options(options)
          super
          @username                = @options.delete(:username)
          @hostname                = @options.delete(:hostname)
          @port                    = @options[:port] # don't delete from options
          @connection_retries      = @options.delete(:connection_retries)
          @connection_retry_sleep  = @options.delete(:connection_retry_sleep)
          @max_ssh_sessions        = @options.delete(:max_ssh_sessions)
          @max_wait_until_ready    = @options.delete(:max_wait_until_ready)
          @ssh_gateway             = @options.delete(:ssh_gateway)
          @ssh_gateway_username    = @options.delete(:ssh_gateway_username)
          @ssh_gateway_port        = @options.delete(:ssh_gateway_port)
          @ssh_http_proxy          = @options.delete(:ssh_http_proxy)
          @ssh_http_proxy_user     = @options.delete(:ssh_http_proxy_user)
          @ssh_http_proxy_password = @options.delete(:ssh_http_proxy_password)
          @ssh_http_proxy_port     = @options.delete(:ssh_http_proxy_port)
        end

        # Returns a connection session, or establishes one when invoked the
        # first time.
        #
        # @param retry_options [Hash] retry options for the initial connection
        # @return [Net::SSH::Connection::Session] the SSH connection session
        # @api private
        def session(retry_options = {})
          if ssh_gateway
            @session ||= establish_connection_via_gateway({
              retries: connection_retries.to_i,
              delay: connection_retry_sleep.to_i,
            }.merge(retry_options))
          else
            @session ||= establish_connection({
              retries: connection_retries.to_i,
              delay: connection_retry_sleep.to_i,
            }.merge(retry_options))
          end
        end

        # String representation of object, reporting its connection details and
        # configuration.
        #
        # @api private
        def to_s
          "#{username}@#{hostname}<#{options.inspect}>"
        end
      end

      private

      # Builds the hash of options needed by the Connection object on
      # construction.
      #
      # @param data [Hash] merged configuration and mutable state data
      # @return [Hash] hash of connection options
      # @api private
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def connection_options(data)
        opts = {
          logger:,
          user_known_hosts_file: "/dev/null",
          hostname: data[:hostname],
          port: data[:port],
          username: data[:username],
          compression: data[:compression],
          compression_level: data[:compression_level],
          keepalive: data[:keepalive],
          keepalive_interval: data[:keepalive_interval],
          keepalive_maxcount: data[:keepalive_maxcount],
          timeout: data[:connection_timeout],
          connection_retries: data[:connection_retries],
          connection_retry_sleep: data[:connection_retry_sleep],
          max_ssh_sessions: data[:max_ssh_sessions],
          max_wait_until_ready: data[:max_wait_until_ready],
          ssh_gateway: data[:ssh_gateway],
          ssh_gateway_username: data[:ssh_gateway_username],
          ssh_gateway_port: data[:ssh_gateway_port],
        }

        if data[:ssh_key] && !data[:password]
          opts[:keys_only] = true
          opts[:keys] = Array(data[:ssh_key])
          opts[:auth_methods] = ["publickey"]
        end

        if data[:ssh_http_proxy]
          options_http_proxy = {}
          options_http_proxy[:user] = data[:ssh_http_proxy_user]
          options_http_proxy[:password] = data[:ssh_http_proxy_password]
          opts[:proxy] = Net::SSH::Proxy::HTTP.new(data[:ssh_http_proxy], data[:ssh_http_proxy_port], options_http_proxy)
        end

        if data[:ssh_key_only]
          opts[:auth_methods] = ["publickey"]
        end

        opts[:password] = data[:password]           if data.key?(:password)
        opts[:forward_agent] = data[:forward_agent] if data.key?(:forward_agent)
        opts[:verbose] = data[:verbose].to_sym      if data.key?(:verbose)

        # disable host key verification. The hash key and value to use
        # depend on the version of net-ssh in use
        opts[verify_host_key_option] = verify_host_key_value

        opts
      end

      #
      # Returns the correct host-key-verification option key to use depending
      # on what version of net-ssh is in use. In net-ssh <= 4.1, the supported
      # parameter is `paranoid` but in 4.2, it became `verify_host_key`
      #
      # `verify_host_key` does not work in <= 4.1, and `paranoid` throws
      # deprecation warnings in >= 4.2.
      #
      # While the "right thing" to do would be to pin train's dependency on
      # net-ssh to ~> 4.2, this will prevent InSpec from being used in
      # Chef v12 because of it pinning to a v3 of net-ssh.
      #
      def verify_host_key_option
        current_net_ssh = Net::SSH::Version::CURRENT
        new_option_version = Net::SSH::Version[4, 2, 0]

        current_net_ssh >= new_option_version ? :verify_host_key : :paranoid
      end

      #
      # Returns the correct host-key-verification option value to use depending
      # on what version of net-ssh is in use. In net-ssh <= 5, the supported
      # parameter is false but in 5.0, it became `:never`
      #
      def verify_host_key_value
        current_net_ssh = Net::SSH::Version::CURRENT
        new_option_version = Net::SSH::Version[5, 0, 0]

        current_net_ssh >= new_option_version ? :never : false
      end

      # Creates a new SSH Connection instance and save it for potential future
      # reuse.
      #
      # @param options [Hash] connection options
      # @return [Ssh::Connection] an SSH Connection instance
      # @api private
      def create_new_connection(options, &block)
        cleanup!
        @connection_options = options
        @connection = Kitchen::Transport::Ssh::Connection.new(options, &block)
      end

      # Return the last saved SSH connection instance.
      #
      # @return [Ssh::Connection] an SSH Connection instance
      # @api private
      def reuse_connection
        string_to_mask = "[SSH] reusing existing connection #{@connection}"
        masked_string = Util.mask_values(string_to_mask, %w{password ssh_http_proxy_password})
        logger.debug(masked_string)
        yield @connection if block_given?
        @connection
      end
    end
  end
end

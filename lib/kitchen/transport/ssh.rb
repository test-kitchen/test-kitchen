# -*- encoding: utf-8 -*-
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

require "kitchen"

require "net/ssh"
require "net/scp"

module Kitchen

  module Transport

    # Wrapped exception for any internally raised SSH-related errors.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class SshFailed < TransportFailed; end

    # Class to help establish SSH connections, issue remote commands, and
    # transfer files between a local system and remote node.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Ssh < Kitchen::Transport::Base

      default_config :port, 22
      default_config :username, "root"
      default_config :connection_timeout, 15
      default_config :connection_retries, 5
      default_config :connection_retry_sleep, 1
      default_config :max_wait_until_ready, 600

      def connection(state, &block)
        options = connection_options(config.to_hash.merge(state))

        if @connection && @connection_options == options
          reuse_connection(&block)
        else
          create_new_connection(options, &block)
        end
      end

      # TODO: comment
      class Connection < Kitchen::Transport::Base::Connection

        # (see Base#execute)
        def execute(command)
          logger.debug("[SSH] #{self} (#{command})")
          exit_code = execute_with_exit_code(command)

          if exit_code != 0
            raise Transport::SshFailed,
              "SSH exited (#{exit_code}) for command: [#{command}]"
          end
        end

        # (see Base#login_command)
        def login_command
          args  = %W[ -o UserKnownHostsFile=/dev/null ]
          args += %W[ -o StrictHostKeyChecking=no ]
          args += %W[ -o IdentitiesOnly=yes ] if options[:keys]
          args += %W[ -o LogLevel=#{logger.debug? ? "VERBOSE" : "ERROR"} ]
          if options.key?(:forward_agent)
            args += %W[ -o ForwardAgent=#{options[:forward_agent] ? "yes" : "no"} ]
          end
          Array(options[:keys]).each { |ssh_key| args += %W[ -i #{ssh_key} ] }
          args += %W[ -p #{port} ]
          args += %W[ #{username}@#{hostname} ]

          LoginCommand.new(["ssh", *args])
        end

        # (see Base#shutdown)
        def shutdown
          return if @session.nil?

          logger.debug("[SSH] closing connection to #{self}")
          session.close
        ensure
          @session = nil
        end

        # (see Base#upload)
        def upload(locals, remote)
          Array(locals).each do |local|
            opts = File.directory?(local) ? { :recursive => true } : {}

            session.scp.upload!(local, remote, opts) do |_ch, name, sent, total|
              logger.debug("Uploaded #{name} (#{total} bytes)") if sent == total
            end
          end
        end

        # (see Base#wait_until_ready)
        def wait_until_ready
          delay = 3
          session(
            :retries  => max_wait_until_ready / delay,
            :delay    => delay,
            :message  => "Waiting for SSH service on #{hostname}:#{port}, " \
              "retrying in #{delay} seconds"
          )
          execute("")
        end

        private

        RESCUE_EXCEPTIONS_ON_ESTABLISH = [
          Errno::EACCES, Errno::EADDRINUSE, Errno::ECONNREFUSED,
          Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EHOSTUNREACH,
          Net::SSH::Disconnect, Net::SSH::AuthenticationFailed, Timeout::Error
        ].freeze

        attr_reader :connection_retries

        attr_reader :connection_retry_sleep

        attr_reader :hostname

        attr_reader :max_wait_until_ready

        attr_reader :username

        attr_reader :port

        # Establish a connection session to the remote host.
        #
        # @return [Net::SSH::Connection::Session] the SSH connection session
        # @api private
        def establish_connection(opts)
          logger.debug("[SSH] opening connection to #{self}")
          Net::SSH.start(hostname, username, options)
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
            raise
          end
        end

        # Execute a remote command and return the command's exit code.
        #
        # @param cmd [String] command string to execute
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

        # (see Base#init_options)
        def init_options(options)
          super
          @username               = @options.delete(:username)
          @hostname               = @options.delete(:hostname)
          @port                   = @options[:port] # don't delete from options
          @connection_retries     = @options.delete(:connection_retries)
          @connection_retry_sleep = @options.delete(:connection_retry_sleep)
          @max_wait_until_ready   = @options.delete(:max_wait_until_ready)
        end

        # Establish a connection session to the remote host.
        #
        # @return [Net::SSH::Connection::Session] the SSH connection session
        # @api private
        def session(connection_options = {})
          @session ||= establish_connection({
            :retries => connection_retries.to_i,
            :delay   => connection_retry_sleep.to_i
          }.merge(connection_options))
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

      def connection_options(data)
        opts = {
          :logger                 => logger,
          :user_known_hosts_file  => "/dev/null",
          :paranoid               => false,
          :hostname               => data[:hostname],
          :port                   => data[:port],
          :username               => data[:username],
          :timeout                => data[:connection_timeout],
          :connection_retries     => data[:connection_retries],
          :connection_retry_sleep => data[:connection_retry_sleep],
          :max_wait_until_ready   => data[:max_wait_until_ready]
        }

        opts[:keys_only] = true                     if data[:ssh_key]
        opts[:keys] = Array(data[:ssh_key])         if data[:ssh_key]
        opts[:password] = data[:password]           if data.key?(:password)
        opts[:forward_agent] = data[:forward_agent] if data.key?(:forward_agent)

        opts
      end

      def create_new_connection(options, &block)
        if @connection
          logger.debug("[SSH] shutting previous connection #{@connection}")
          @connection.shutdown
        end

        @connection_options = options
        @connection = Kitchen::Transport::Ssh::Connection.new(options, &block)
      end

      def reuse_connection
        logger.debug("[SSH] reusing existing connection #{@connection}")
        yield @connection if block_given?
        @connection
      end
    end
  end
end

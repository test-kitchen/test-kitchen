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

# WORKAROUND: Avoid seeing the errors:
# => WARNING: Could not load IOV methods. Check your GSSAPI C library for an update
# => WARNING: Could not load AEAD methods. Check your GSSAPI C library for an update
# by setting $VERBOSE=nil momentarily
if defined?(WinRM).nil?
  verbose_bk = $VERBOSE
  $VERBOSE = nil
  require "winrm"
  $VERBOSE = verbose_bk
end

require "kitchen"
require "kitchen/transport/winrm/command_executor"
require "kitchen/transport/winrm_file_transfer/remote_file"
require "kitchen/transport/winrm_file_transfer/remote_zip_file"

module Kitchen

  module Transport

    # Wrapped exception for any internally raised WinRM-related errors.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class WinrmFailed < TransportFailed; end

    # Class to help establish WinRM connections, issue remote commands, and
    # transfer files between a local system and remote node.
    #
    # @author Salim Afiune <salim@afiunemaya.com.mx>
    class Winrm < Kitchen::Transport::Base

      default_config :port, 5985
      default_config :username, ".\\administrator"
      default_config :password, nil
      default_config :endpoint_template, "http://%{hostname}:%{port}/wsman"
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
          logger.debug("[WinRM] #{self} (#{command})")
          exit_code, stderr = execute_with_exit_code(command)

          if exit_code != 0
            log_stderr_on_warn(stderr)
            raise Transport::WinrmFailed,
              "WinRM exited (#{exit_code}) for command: [#{command}]"
          elsif !stderr.empty?
            log_stderr_on_warn(stderr)
            raise Transport::WinrmFailed,
              "WinRM exited (#{exit_code}) but contained a STDERR stream " \
              "for command: [#{command}]"
          end
        end

        # (see Base#wait_until_ready)
        def wait_until_ready
          delay = 3
          exit_code, stderr = execute_with_exit_code(
            PING_COMMAND,
            :retries  => max_wait_until_ready / delay,
            :delay    => delay,
            :message  => "Waiting for WinRM service on #{endpoint}, " \
              "retrying in #{delay} seconds"
          )

          if exit_code != 0
            log_stderr_on_warn(stderr)
            raise Transport::WinrmFailed,
              "WinRM exited (#{exit_code}) for command: [#{PING_COMMAND}]"
          end
        end

        private

        PING_COMMAND = "Write-Host '[WinRM] Established\n'".freeze

        RESCUE_EXCEPTIONS_ON_ESTABLISH = [
          Errno::EACCES, Errno::EADDRINUSE, Errno::ECONNREFUSED,
          Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EHOSTUNREACH,
          ::WinRM::WinRMHTTPTransportError, ::WinRM::WinRMAuthorizationError,
          HTTPClient::KeepAliveDisconnected
        ].freeze

        attr_reader :connection_retries

        attr_reader :connection_retry_sleep

        attr_reader :endpoint

        attr_reader :max_wait_until_ready

        attr_reader :winrm_transport

        def execute_with_exit_code(command, opts = {})
          opts = {
            :retries => connection_retries.to_i,
            :delay   => connection_retry_sleep.to_i
          }.merge(opts)

          retryable(opts) do
            logger.debug("[WinRM] opening connection to #{self}")
            response = session.run_powershell_script(command) do |stdout, _|
              logger << stdout if stdout
            end

            [response[:exitcode], stderr_from_response(response)]
          end
        end

        # (see Base#init_options)
        def init_options(options)
          super
          @endpoint           = @options.delete(:endpoint)
          @winrm_transport    = @options.delete(:winrm_transport)
          @connection_retries = @options.delete(:connection_retries)
          @connection_retry_sleep = @options.delete(:connection_retry_sleep)
          @max_wait_until_ready   = @options.delete(:max_wait_until_ready)
        end

        def log_stderr_on_warn(stderr)
          error_regexp = /<S S=\"Error\">/

          if stderr.grep(error_regexp).empty?
            stderr.join.
              split("\r\n").
              each { |line| logger.warn(line) }
          else
            stderr.join.
              split(error_regexp)[1..-2].
              map! { |line| line.sub(/_x000D__x000A_<\/S>/, "").rstrip }.
              each { |line| logger.warn(line) }
          end
        end

        def retryable(opts)
          yield
        rescue *RESCUE_EXCEPTIONS_ON_ESTABLISH => e
          if (opts[:retries] -= 1) > 0
            message = if opts[:message]
              logger.debug("[WinRM] connection failed (#{e.inspect})")
              opts[:message]
            else
              "[WinRM] connection failed, " \
                "retrying in #{opts[:delay]} seconds (#{e.inspect})"
            end
            logger.info(message)
            sleep(opts[:delay])
            retry
          else
            logger.warn("[WinRM] connection failed, terminating (#{e.inspect})")
            raise
          end
        end

        def session
          @session ||= ::WinRM::WinRMWebService.new(
            endpoint, winrm_transport, options)
        end

        def stderr_from_response(response)
          response[:data].select { |hash| hash.key?(:stderr) }.
            map { |hash| hash[:stderr] }
        end

        # String representation of object, reporting its connection details and
        # configuration.
        #
        # @api private
        def to_s
          "#{winrm_transport}::#{endpoint}<#{options.inspect}>"
        end
      end

      private

      def connection_options(data)
        opts = {
          :logger                 => logger,
          :winrm_transport        => :plaintext,
          :disable_sspi           => true,
          :basic_auth_only        => true,
          :endpoint               => data[:endpoint_template] % data,
          :user                   => data[:username],
          :pass                   => data[:password],
          :connection_retries     => data[:connection_retries],
          :connection_retry_sleep => data[:connection_retry_sleep],
          :max_wait_until_ready   => data[:max_wait_until_ready]
        }

        opts
      end

      def create_new_connection(options, &block)
        if @connection
          logger.debug("[WinRM] shutting previous connection #{@connection}")
          @connection.shutdown
        end

        @connection_options = options
        @connection = Kitchen::Transport::Winrm::Connection.new(options, &block)
      end

      def reuse_connection
        logger.debug("[WinRM] reusing existing connection #{@connection}")
        yield @connection if block_given?
        @connection
      end
    end
  end
end

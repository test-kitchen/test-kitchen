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

require "logger"
require "net/ssh"
require "net/scp"
require "socket"

module Kitchen

  module Transport

    # Class to help establish SSH connections, issue remote commands, and
    # transfer files between a local system and remote node.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Ssh < Kitchen::Transport::Base
      
      default_config :sudo, true
      default_config :shell, "bourne"

      # (see Base#execute)
      def execute(command)
        logger.debug("[#{self.class}] #{self} (#{command})")
        exit_code = execute_with_exit(env_command(command))

        if exit_code != 0
          raise TransportFailed, "[#{name}] exited (#{exit_code}) for command: [#{command}]"
        end
      end

      # (see Base#upload!)
      def upload!(local, remote, options = {}, &progress)
        options = { :recursive => true }.merge(options)

        if progress.nil?
          progress = lambda { |_ch, name, sent, total|
            if sent == total
              logger.debug("Uploaded #{name} (#{total} bytes)")
            end
          }
        end

        local.each do |path| 
          session.scp.upload!(path, remote, options, &progress) 
        end
      end

      # (see Base#disconnect)
      def disconnect
        return if @session.nil?

        logger.debug("[#{self.class}] closing connection to #{self}")
        session.shutdown!
      ensure
        @session = nil
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
      
      # (see Base#default_port)
      def default_port
        @default_port ||= 22
      end

      private

      # TCP socket exceptions
      SOCKET_EXCEPTIONS = [
        SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH,
        Errno::ENETUNREACH, IOError
      ]

      # (see Base#establish_connection)
      def establish_connection
        rescue_exceptions = [
          Errno::EACCES, Errno::EADDRINUSE, Errno::ECONNREFUSED,
          Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EHOSTUNREACH,
          Net::SSH::Disconnect
        ]
        retries = 3

        begin
          logger.debug("[#{self.class}] opening connection to #{self}")
          Net::SSH.start(hostname, username, options)
        rescue *rescue_exceptions => e
          retries -= 1
          if retries > 0
            logger.info("[#{self.class}] connection failed, retrying (#{e.inspect})")
            sleep 1
            retry
          else
            logger.warn("[#{self.class}] connection failed, terminating (#{e.inspect})")
            raise
          end
        end
      end

      # (see Base#execute_with_exit)
      def execute_with_exit(command)
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

      # (see Base#env_command)
      def env_command(command)
        env = "env"
        env << " http_proxy=#{config[:http_proxy]}"   if config[:http_proxy]
        env << " https_proxy=#{config[:https_proxy]}" if config[:https_proxy]

        env == "env" ? command : "#{env} #{command}"
      end
      
      # (see Base#test_connection)
      def test_connection
        socket = TCPSocket.new(hostname, port)
        IO.select([socket], nil, nil, 5)
      rescue *SOCKET_EXCEPTIONS
        sleep 2
        false
      rescue Errno::EPERM, Errno::ETIMEDOUT
        false
      ensure
        socket && socket.close
      end

      # (see Base#build_transport_args)
      def build_transport_args(state)
        combined = state.to_hash.merge(config)

        opts = Hash.new
        opts[:user_known_hosts_file] = "/dev/null"
        opts[:paranoid] = false
        opts[:keys_only] = true if combined[:ssh_key]
        opts[:password] = combined[:password] if combined[:password]
        opts[:forward_agent] = combined[:forward_agent] if combined.key? :forward_agent
        opts[:port] = combined[:port] if combined[:port]
        opts[:keys] = Array(combined[:ssh_key]) if combined[:ssh_key]
        opts[:logger] = logger

        opts
      end
    end
  end
end

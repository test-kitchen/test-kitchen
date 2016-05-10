# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

require "kitchen/errors"
require "kitchen/login_command"

module Kitchen

  # Wrapped exception for any internally raised SSH-related errors.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class SSHFailed < TransientFailure; end

  # Class to help establish SSH connections, issue remote commands, and
  # transfer files between a local system and remote node.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class SSH

    # Constructs a new SSH object.
    #
    # @example basic usage
    #
    #   ssh = Kitchen::SSH.new("remote.example.com", "root")
    #   ssh.exec("sudo apt-get update")
    #   ssh.upload!("/tmp/data.txt", "/var/lib/data.txt")
    #   ssh.shutdown
    #
    # @example block usage
    #
    #   Kitchen::SSH.new("remote.example.com", "root") do |ssh|
    #     ssh.exec("sudo apt-get update")
    #     ssh.upload!("/tmp/data.txt", "/var/lib/data.txt")
    #   end
    #
    # @param hostname [String] the remote hostname (IP address, FQDN, etc.)
    # @param username [String] the username for the remote host
    # @param options [Hash] configuration options
    # @option options [Logger] :logger the logger to use
    #   (default: `::Logger.new(STDOUT)`)
    # @yield [self] if a block is given then the constructed object yields
    #   itself and calls `#shutdown` at the end, closing the remote connection
    def initialize(hostname, username, options = {})
      @hostname = hostname
      @username = username
      @options = options.dup
      @logger = @options.delete(:logger) || ::Logger.new(STDOUT)

      if block_given?
        yield self
        shutdown
      end
    end

    # Execute a command on the remote host.
    #
    # @param cmd [String] command string to execute
    # @raise [SSHFailed] if the command does not exit with a 0 code
    def exec(cmd)
      logger.debug("[SSH] #{self} (#{cmd})")
      exit_code = exec_with_exit(cmd)

      if exit_code != 0
        raise SSHFailed, "SSH exited (#{exit_code}) for command: [#{cmd}]"
      end
    end

    # Uploads a local file to remote host.
    #
    # @param local [String] path to local file
    # @param remote [String] path to remote file destination
    # @param options [Hash] configuration options that are passed to
    #   `Net::SCP.upload`
    # @see http://net-ssh.github.io/net-scp/classes/Net/SCP.html#method-i-upload
    def upload!(local, remote, options = {}, &progress)
      if progress.nil?
        progress = lambda { |_ch, name, sent, total|
          if sent == total
            logger.debug("Uploaded #{name} (#{total} bytes)")
          end
        }
      end

      session.scp.upload!(local, remote, options, &progress)
    end

    def upload(local, remote, options = {}, &progress)
      if progress.nil?
        progress = lambda { |_ch, name, sent, total|
          if sent == total
            logger.debug("Async Uploaded #{name} (#{total} bytes)")
          end
        }
      end

      session.scp.upload(local, remote, options, &progress)
    end

    # Uploads a recursive directory to remote host.
    #
    # @param local [String] path to local file or directory
    # @param remote [String] path to remote file destination
    # @param options [Hash] configuration options that are passed to
    #   `Net::SCP.upload`
    # @option options [true,false] :recursive recursive copy (default: `true`)
    # @see http://net-ssh.github.io/net-scp/classes/Net/SCP.html#method-i-upload
    def upload_path!(local, remote, options = {}, &progress)
      options = { :recursive => true }.merge(options)

      upload!(local, remote, options, &progress)
    end

    def upload_path(local, remote, options = {}, &progress)
      options = { :recursive => true }.merge(options)
      upload(local, remote, options, &progress)
    end

    # Shuts down the session connection, if it is still active.
    def shutdown
      return if @session.nil?

      logger.debug("[SSH] closing connection to #{self}")
      session.shutdown!
    ensure
      @session = nil
    end

    # Blocks until the remote host's SSH TCP port is listening.
    def wait
      logger.info("Waiting for #{hostname}:#{port}...") until test_ssh
    end

    # Builds a LoginCommand which can be used to open an interactive session
    # on the remote host.
    #
    # @return [LoginCommand] the login command
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

      LoginCommand.new("ssh", args)
    end

    private

    # TCP socket exceptions
    SOCKET_EXCEPTIONS = [
      SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH,
      Errno::ENETUNREACH, IOError
    ]

    # @return [String] the remote hostname
    # @api private
    attr_reader :hostname

    # @return [String] the username for the remote host
    # @api private
    attr_reader :username

    # @return [Hash] SSH options, passed to `Net::SSH.start`
    attr_reader :options

    # @return [Logger] the logger to use
    # @api private
    attr_reader :logger

    # Builds the Net::SSH session connection or returns the existing one if
    # built.
    #
    # @return [Net::SSH::Connection::Session] the SSH connection session
    # @api private
    def session
      @session ||= establish_connection
    end

    # Establish a connection session to the remote host.
    #
    # @return [Net::SSH::Connection::Session] the SSH connection session
    # @api private
    def establish_connection
      rescue_exceptions = [
        Errno::EACCES, Errno::EADDRINUSE, Errno::ECONNREFUSED,
        Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EHOSTUNREACH,
        Net::SSH::Disconnect, Net::SSH::AuthenticationFailed, Net::SSH::ConnectionTimeout
      ]
      retries = options[:ssh_retries] || 3

      begin
        logger.debug("[SSH] opening connection to #{self}")
        Net::SSH.start(hostname, username, options)
      rescue *rescue_exceptions => e
        retries -= 1
        if retries > 0
          logger.info("[SSH] connection failed, retrying (#{e.inspect})")
          sleep options[:ssh_timeout] || 1
          retry
        else
          logger.warn("[SSH] connection failed, terminating (#{e.inspect})")
          raise
        end
      end
    end

    # String representation of object, reporting its connection details and
    # configuration.
    #
    # @api private
    def to_s
      "#{username}@#{hostname}:#{port}<#{options.inspect}>"
    end

    # @return [Integer] SSH port (default: 22)
    # @api private
    def port
      options.fetch(:port, 22)
    end

    # Execute a remote command and return the command's exit code.
    #
    # @param cmd [String] command string to execute
    # @return [Integer] the exit code of the command
    # @api private
    def exec_with_exit(cmd)
      exit_code = nil
      session.open_channel do |channel|

        channel.request_pty

        channel.exec(cmd) do |_ch, _success|

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

    # Test a remote TCP socket (presumably SSH) for connectivity.
    #
    # @return [true,false] a truthy value if the socket is ready and false
    #   otherwise
    # @api private
    def test_ssh
      socket = TCPSocket.new(hostname, port)
      IO.select([socket], nil, nil, 5)
    rescue *SOCKET_EXCEPTIONS
      sleep options[:ssh_timeout] || 2
      false
    rescue Errno::EPERM, Errno::ETIMEDOUT
      false
    ensure
      socket && socket.close
    end
  end
end

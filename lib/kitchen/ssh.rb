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

require 'logger'
require 'net/ssh'
require 'net/scp'
require 'socket'

require 'kitchen/errors'
require 'kitchen/login_command'

module Kitchen

  # Wrapped exception for any internally raised SSH-related errors.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class SSHFailed < TransientFailure ; end

  # Class to help establish SSH connections, issue remote commands, and
  # transfer files between a local system and remote node.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class SSH

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

    def exec(cmd)
      logger.debug("[SSH] #{self} (#{cmd})")
      exit_code = exec_with_exit(cmd)

      if exit_code != 0
        raise SSHFailed, "SSH exited (#{exit_code}) for command: [#{cmd}]"
      end
    end

    def upload!(local, remote, options = {}, &progress)
      if progress.nil?
        progress = lambda { |ch, name, sent, total|
          if sent == total
            logger.info("Uploaded #{name} (#{total} bytes)")
          end
        }
      end

      session.scp.upload!(local, remote, options, &progress)
    end

    def upload_path!(local, remote, options = {}, &progress)
      options = { :recursive => true }.merge(options)

      upload!(local, remote, options, &progress)
    end

    def shutdown
      return if @session.nil?

      logger.debug("[SSH] closing connection to #{self}")
      session.shutdown!
    ensure
      @session = nil
    end

    def wait
      logger.info("Waiting for #{hostname}:#{port}...") until test_ssh
    end

    def login_command
      args  = %W{ -o UserKnownHostsFile=/dev/null }
      args += %W{ -o StrictHostKeyChecking=no }
      args += %W{ -o LogLevel=#{logger.debug? ? "VERBOSE" : "ERROR"} }
      Array(options[:keys]).each { |ssh_key| args += %W{ -i #{ssh_key}} }
      args += %W{ -p #{port}}
      args += %W{ #{username}@#{hostname}}

      LoginCommand.new(["ssh", *args])
    end

    private

    attr_reader :hostname, :username, :options, :logger

    def session
      @session ||= begin
        logger.debug("[SSH] opening connection to #{self}")
        Net::SSH.start(hostname, username, options)
      end
    end

    def to_s
      "#{username}@#{hostname}:#{port}<#{options.inspect}>"
    end

    def port
      options.fetch(:port, 22)
    end

    def exec_with_exit(cmd)
      exit_code = nil
      session.open_channel do |channel|

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
      session.loop
      exit_code
    end

    def test_ssh
      socket = TCPSocket.new(hostname, port)
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
  end
end

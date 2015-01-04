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

require "logger"

require "kitchen/errors"
require "kitchen/login_command"
require "kitchen/transport/winrm_file_transfer/remote_file"
require "kitchen/transport/winrm_file_transfer/remote_zip_file"

module Kitchen

  module Transport

    # Class to help establish WinRM connections, issue remote commands, and
    # transfer files between a local system and remote node.
    #
    # @author Salim Afiune <salim@afiunemaya.com.mx>
    class Winrm < Kitchen::Transport::Base

      default_config :shell, "powershell"
      default_config :sudo, false

      # (see Base#execute)
      def execute(command, shell = :powershell)
        return if command.nil?
        logger.debug("[#{self.class}] shell => #{shell}, (#{command})")
        exit_code, stderr = execute_with_exit(env_command(command), shell)
        if exit_code != 0 || !stderr.empty?
          raise TransportFailed,
            "Transport WinRM exited (#{exit_code}) using shell [#{shell}] for " \
            "command: [#{command}]\nREMOTE ERROR:\n" \
            "#{human_err_msg(stderr)}"
        end
      end

      # Simple function that will help us running a command with an
      # specific shell without printing the output to the end user.
      #
      # @param command [String] The command to execute
      # @return [Hash] Information about the STDOUT, STDERR and EXIT_CODE
      def powershell(command)
        run(command, :powershell)
      end

      def cmd(command)
        run(command, :cmd)
      end

      def wql(query)
        run(query, :wql)
      end

      # (see Base#upload!)
      def upload!(local_path, remote_path, &block)
        local_path = [local_path] if local_path.is_a? String
        file = create_remote_file(local_path, remote_path)
        file.upload(&block)
      ensure
        file.close unless file.nil?
      end

      # Convert a complex CLIXML Error to a human readable format
      #
      # @param msg [String] The error message
      # @return [String] The error message with human format
      def human_err_msg(msg)
        err_msg = ""

        while msg.size > 0
          line = msg.shift
          if line.include?("CLIXML")
            msg.unshift(line)
            break
          else
            err_msg << line
          end
        end

        unless msg.empty?
          msg = msg.join
          human = msg.split(/<S S=\"Error\">/).map! do |a|
            a.gsub(/_x000D__x000A_<\/S>/, "")
          end
          human.shift
          human.pop
          err_msg << human.join("\n")
        end
        err_msg
      end

      # (see Base#login_command)
      def login_command
        rdp_file = File.join(config[:kitchen_root], ".kitchen", "#{instance.name}.rdp")
        case RUBY_PLATFORM
        when /cygwin|mswin|mingw|bccwin|wince|emx/
          windows_login_command(rdp_file)
        when /darwin/
          mac_login_command(rdp_file)
        else
          raise TransportFailed,
            "[#{self.class}] Cannot open Remote Desktop App: Unsupported platform"
        end
      end

      # (see Base#default_port)
      def default_port
        @default_port ||= 5985
      end

      private

      def windows_login_command(rdp_file)
        # On Windows, use default RDP software
        rdp_cmd = "mstsc"
        File.open(rdp_file, "w") do |f|
          f.write(
            <<-RDP.gsub(/^ {16}/, "")
              full address:s:#{@hostname}:3389
              username:s:#{@username}
            RDP
          )
        end
        LoginCommand.new([rdp_cmd, rdp_file])
      end

      def mac_login_command(rdp_file)
        # On MAC, we should have /Applications/Remote\ Desktop\ Connection.app
        rdc_path = "/Applications/Remote\ Desktop\ Connection.app"
        unless File.exist?(rdc_path)
          raise TransportFailed, "RDC application not found at path: #{rdc_path}"
        end
        rdc_cmd = File.join(rdc_path, "Contents/MacOS/Remote\ Desktop\ Connection")
        File.open(rdp_file, "w") do |f|
          f.write(
            <<-RDP.gsub(/^ {16}/, "")
              <dict>
                <key>ConnectionString</key>
                <string>#{@hostname}:3389</string>
                <key>UserName</key>
                <string>#{@username}</string>
              </dict>
            RDP
          )
        end
        LoginCommand.new([rdc_cmd, rdp_file])
      end

      def create_remote_file(local_paths, remote_path)
        if local_paths.count == 1 && !File.directory?(local_paths[0])
          return WinRMFileTransfer::RemoteFile.new(logger, session, local_paths[0], remote_path)
        end
        zip_file = WinRMFileTransfer::RemoteZipFile.new(logger, session, remote_path)
        local_paths.each { |path| zip_file.add_file(path) }
        zip_file
      end

      # (see Base#establish_connection)
      def establish_connection
        rescue_exceptions = [
          Errno::EACCES, Errno::EADDRINUSE, Errno::ECONNREFUSED,
          Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EHOSTUNREACH,
          ::WinRM::WinRMHTTPTransportError, ::WinRM::WinRMAuthorizationError
        ]
        retries ||= 3

        logger.debug("[#{self.class}] opening connection to #{self}")
        socket = ::WinRM::WinRMWebService.new(*build_winrm_options)
        socket.set_timeout(timeout_in_seconds)
        socket
      rescue *rescue_exceptions => e
        if (retries -= 1) > 0
          logger.info("[#{self.class}] connection failed, retrying (#{e.inspect})")
          sleep 1; retry
        else
          logger.warn("[#{self.class}] connection failed, terminating (#{e.inspect})")
          raise
        end
      end

      # Timeout in seconds
      #
      # @return [Number] Timeout in seconds
      def timeout_in_seconds
        options.fetch(:timeout_in_seconds, 1800)
      end

      # String endpoint to connect thru WinRM Web Service
      #
      # @return [String] The endpoint
      def endpoint
        "http://#{@hostname}:#{port}/wsman"
      end

      # (see Base#execute_with_exit)
      def execute_with_exit(command, shell = :powershell)
        raise TransportFailed, :shell => shell unless [:powershell, :cmd, :wql].include?(shell)
        winrm_err = []
        logger.debug("[#{self.class}] #{shell} executing:\n#{command}")
        begin
          output = session.send(shell, command) do |stdout, stderr|
            logger << stdout if stdout
            winrm_err << stderr if stderr
          end
        rescue => e
          raise TransportFailed,
            "[#{self.class}] #{e.message} using shell: [#{shell}] and command: [#{command}]"
        end
        logger.debug("Output: #{output.inspect}")
        [output[:exitcode], winrm_err]
      end

      # Simple function that will help us running a command with an
      # specific shell without printing the output to the end user.
      #
      # @param command [String] The command to execute
      # @param shell[String] The destination file path on the guest
      # @return [Hash] Information about the STDOUT, STDERR and EXIT_CODE
      def run(command, shell)
        raise TransportFailed, :shell => shell unless [:powershell, :cmd, :wql].include?(shell)
        logger.debug("[#{self.class}] #{shell} running:\n#{command}")
        begin
          session.send(shell, command)
        rescue => e
          raise TransportFailed,
            "[#{self.class}] #{e.message} using shell: [#{shell}] and command: [#{command}]"
        end
      end

      # (see Base#env_command)
      def env_command(command)
        env = " $ProgressPreference='SilentlyContinue';"
        env << " $env:http_proxy=\"#{config[:http_proxy]}\";"   if config[:http_proxy]
        env << " $env:https_proxy=\"#{config[:https_proxy]}\";" if config[:https_proxy]

        env == "" ? command : "#{env} #{command}"
      end

      # (see Base#test_connection)
      def test_connection
        exitcode, _error_msg = execute_with_exit(
          "Write-Host '[Server] Reachable...\n'",
          :powershell
        )
        exitcode.zero?
      rescue
        sleep 5
        false
      end

      # (see Base#build_transport_args)
      def build_transport_args(state)
        combined = config.to_hash.merge(state)

        opts = Hash.new
        [:hostname, :username, :password, :port].each do |key|
          opts[key] = combined[key] if combined[key]
        end
        opts[:forward_agent]  = combined[:forward_agent] if combined.key? :forward_agent
        opts[:logger]         = logger
        opts
      end

      # Build the WinRM options to connect
      #
      # @return endpoint [String] Information about the host and port
      # @return connection_type [String] Plaintext
      # @return options [Hash] Necesary options to connect to the remote host
      def build_winrm_options
        opts = Hash.new

        opts[:user] = username
        opts[:pass] = options[:password] if options[:password]
        opts[:host] = hostname
        opts[:port] = port
        opts[:operation_timeout] = timeout_in_seconds
        opts[:basic_auth_only] = true
        opts[:disable_sspi] = true

        [endpoint, :plaintext, opts]
      end
    end
  end
end

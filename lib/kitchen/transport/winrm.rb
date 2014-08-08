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

module Kitchen

  module Transport

    # Class to help establish WinRM connections, issue remote commands, and
    # transfer files between a local system and remote node.
    #
    # @author Salim Afiune <salim@afiunemaya.com.mx>
    class Winrm < Kitchen::Transport::Base
      
      default_config :shell, "powershell"
      default_config :sudo, false
      default_config :max_threads, 2

      # (see Base#execute)
      def execute(command, shell = :powershell)
      	return if command.nil?
        logger.debug("[#{self.class}] shell => #{shell}, (#{command})")
        exit_code, stderr = execute_with_exit(env_command(command), shell)
        if exit_code != 0 || !stderr.empty?
          raise TransportFailed,
            "Transport WinRM exited (#{exit_code}) using shell [#{shell}] for
              command: [#{command}]\nREMOTE ERROR:\n" +
              human_err_msg(stderr.join)
        end
      end

      # Simple function that will help us running a command with an 
      # specific shell without printing the output to the end user.
      #
      # @param command [String] The command to execute 
      # @param shell[String] The destination file path on the guest
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
      def upload!(local, remote)
        logger.info("Concurrent threads set to :max_threads => #{config[:max_threads]}")
        logger.debug("Upload: #{local} -> #{remote}")
        local = Array.new(1) { local } if local.kind_of? String
        local.each do |path|
          if File.directory?(path)
            upload_directory(path, remote)
          else
            upload_file(path, File.join(remote, File.basename(path)))
          end
        end
        wait_files_transfer
      end

      # [Improvement] Adding Parallelism to improve upload time
      #
      # This method will wait until all the files have been transferred
      def wait_files_transfer
        @threads.each do |thr|
          thr.join
        end
        @threads = Array.new 
      end

      def active_threads
        @threads = Array.new if @threads.nil?
        @threads.size
      end

      # Convert a complex CLIXML Error to a human readable format
      #
      # @param msg [String] The error message
      # @return [String] The error message with human format
      def human_err_msg(msg)
        return msg unless msg.include?("CLIXML")
        human = msg.split(/<S S=\"Error\">/).map! do |a|
          a.gsub(/_x000D__x000A_<\/S>/, "")
        end
        human.shift
        human.pop
        human.join("\n")
      end

      # (see Base#login_command)
      def login_command
        rdp_file = File.join(config[:kitchen_root], ".kitchen", "#{instance.name}.rdp")
        case RUBY_PLATFORM 
        when /cygwin|mswin|mingw|bccwin|wince|emx/
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
        when /darwin/
          # On MAC, we should have /Applications/Remote\ Desktop\ Connection.app
          rdc_path = "/Applications/Remote\ Desktop\ Connection.app"
          raise TransportFailed, "RDC application not found at path: #{rdc_path}" unless File.exists?(rdc_path)
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
      
      # (see Base#establish_connection)
      def establish_connection
        rescue_exceptions = [
          Errno::EACCES, Errno::EADDRINUSE, Errno::ECONNREFUSED,
          Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EHOSTUNREACH,
          ::WinRM::WinRMHTTPTransportError, ::WinRM::WinRMAuthorizationError
        ]
        retries = 3

        begin
          logger.debug("[#{self.class}] opening connection to #{self}")
          socket = ::WinRM::WinRMWebService.new(*build_winrm_options)
          socket.set_timeout(timeout_in_seconds)
          socket
        rescue *rescue_exceptions => e
          if (retries -= 1) > 0
            logger.info("[#{self.class}] connection failed, retrying (#{e.inspect})")
            sleep 1
            retry
          else
            logger.warn("[#{self.class}] connection failed, terminating (#{e.inspect})")
            raise
          end
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
        env = ""
        env << " $env:http_proxy=\"#{config[:http_proxy]}\";"   if config[:http_proxy]
        env << " $env:https_proxy=\"#{config[:https_proxy]}\";" if config[:https_proxy]

        env == "" ? command : "#{env} #{command}"
      end
      
      # (see Base#test_connection)
      def test_connection
        exitcode, _error_msg = execute_with_exit("Write-Host '[Server] Reachable...\n'", :powershell)
        exitcode.zero?
      rescue
        sleep 5
        false
      end

      # (see Base#build_transport_args)
      def build_transport_args(state)
        combined = state.to_hash.merge(config)

        opts = Hash.new
        opts[:port]           = combined[:port] if combined[:port]
        opts[:password]       = combined[:password] if combined[:password]
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

      # Uploads the given file, but only if the target file doesn't exist
      # or its MD5 checksum doens't match the host's source checksum.
      #
      # [Improvement] Adding Parallelism to improve upload time
      #
      # @param [String] The source file path on the host
      # @param [String] The destination file path on the guest
      def upload_file(local, remote)
        logger.debug("Current Threads => #{active_threads}")
        wait_files_transfer if active_threads > config[:max_threads]
        @threads << Thread.new do
          Thread.current["isFileUpload"] = true
          logger.debug("Launched '#{remote}' Thread: #{Thread.current}")
          if should_upload_file?(local, remote)
            tmp_file_path = upload_to_temp_file(local)
            decode_temp_file(tmp_file_path, remote)
          else
            logger.debug("Up to date: #{remote}")
          end
          logger.debug("Finished '#{remote}' Thread: #{Thread.current}")
        end
      end

      # Checks to see if the target file on the guest is missing or out of date.
      #
      # @param [String] The source file path on the host
      # @param [String] The destination file path on the guest
      # @return [Boolean] True if the file is missing or out of date
      def should_upload_file?(local, remote)
        local_md5 = Digest::MD5.file(local).hexdigest
        command = <<-EOH
$dest_file_path = [System.IO.Path]::GetFullPath('#{remote}')

if (Test-Path $dest_file_path) {
  $crypto_prov = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
  try {
    $file = [System.IO.File]::Open($dest_file_path,
      [System.IO.Filemode]::Open, [System.IO.FileAccess]::Read)
    $guest_md5 = ([System.BitConverter]::ToString($crypto_prov.ComputeHash($file)))
    $guest_md5 = $guest_md5.Replace("-","").ToLower()
  }
  finally {
    $file.Dispose()
  }
  if ($guest_md5 -eq '#{local_md5}') {
    exit 0
  }
}
exit 1
        EOH
        powershell(command)[:exitcode] == 1
      end

      # Uploads the given file to a new temp file on the guest
      #
      # @param [String] The source file path on the host
      # @return [String] The temp file path on the guest
      def upload_to_temp_file(local)
        tmp_file_path = File.join(guest_temp_dir, "winrm-upload-#{rand}")
        logger.debug("Uploading '#{local}' to temp file '#{tmp_file_path}'")
        base64_host_file = Base64.encode64(IO.binread(local)).gsub("\n", "")
        base64_host_file.chars.to_a.each_slice(8000 - tmp_file_path.size) do |chunk|
          output = cmd("echo #{chunk.join} >> \"#{tmp_file_path}\"")
          raise_upload_error_if_failed(output, local, tmp_file_path)
        end
        tmp_file_path
      end

      # Recursively uploads the given directory from the host to the guest
      #
      # @param [String] The source file or directory path on the host
      # @param [String] The destination file or directory path on the host
      def upload_directory(local, remote)
        glob_patt = File.join(local, "**/*")
        Dir.glob(glob_patt).select { |f| !File.directory?(f) }.each do |local_file_path|
          remote_file_path = remote_file_path(local, remote, local_file_path)
          upload_file(local_file_path, remote_file_path)
        end
      end

      # Moves and decodes the given file temp file on the guest to its
      # permanent location
      #
      # @param [String] The source base64 encoded temp file path on the guest
      # @param [String] The destination file path on the guest
      def decode_temp_file(local, remote)
        logger.debug("Decoding temp file '#{local}' to '#{remote}'")
        output = powershell <<-EOH
          $tmp_file_path = [System.IO.Path]::GetFullPath('#{local}')
          $dest_file_path = [System.IO.Path]::GetFullPath('#{remote}')

          if (Test-Path $dest_file_path) {
            rm $dest_file_path
          }
          else {
            $dest_dir = ([System.IO.Path]::GetDirectoryName($dest_file_path))
            New-Item -ItemType directory -Force -Path $dest_dir
          }

          $base64_string = Get-Content $tmp_file_path
          $bytes = [System.Convert]::FromBase64String($base64_string)
          [System.IO.File]::WriteAllBytes($dest_file_path, $bytes)
        EOH
        raise_upload_error_if_failed(output, local, remote)
      end

      # Creates a guest file path equivalent from a host file path
      #
      # @param [String] The base host directory we're going to copy from
      # @param [String] The base guest directory we're going to copy to
      # @param [String] A full path to a file on the host underneath local
      # @return [String] The guest file path equivalent
      def remote_file_path(local, remote, local_file_path)
        relative_path = File.dirname(local_file_path[local.length, local_file_path.length])
        File.join(remote, File.basename(local), relative_path, File.basename(local_file_path))
      end

      # Get the guest temporal path to upload temporal files
      #
      # @return [String] The guest temp path
	    def guest_temp_dir
	      @guest_temp ||= (cmd("echo %TEMP%"))[:data][0][:stdout].chomp
	    end

      def raise_upload_error_if_failed(output, from, to)
        raise TransportFailed,
          :from => from,
          :to => to,
          :message => output.inspect unless output[:exitcode].zero?
      end
    end
  end
end

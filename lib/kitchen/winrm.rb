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

  # Wrapped exception for any internally raised WinRM-related errors.
  #
  # @author Salim Afiune <salim@afiunemaya.com.mx>
  class WinRMFailed < TransientFailure; end

  # Class to help establish WinRM connections, issue remote commands, and
  # transfer files between a local system and remote node.
  #
  # @author Salim Afiune <salim@afiunemaya.com.mx>
  class WinRM

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

    def powershell(command)
      run_shell(command, :powershell)
    end

    def cmd(command)
      run_shell(command, :cmd)
    end

    def wql(query)
      run_shell(query, :wql)
    end

    def exec(command, shell = :powershell)
      logger.debug("[WinRM] #{self}, shell => #{shell}, (#{command})")
      exit_code, stderr = execute_shell(command, shell)
      if exit_code != 0 || !stderr.empty?
        raise WinRMFailed,
          "WinRM exited (#{exit_code}) using shell [#{shell}] for
            command: [#{command}]\nREMOTE ERROR:\n" +
            human_err_msg(stderr.join)
      end
    end

    # Uploads the given file or directory from the host to the guest (recursively).
    #
    # @param [String] The source file or directory path on the host
    # @param [String] The destination file or directory path on the host
    def upload!(local, remote)
      logger.debug("Upload: #{local} -> #{remote}")
      if File.directory?(local)
        upload_directory(local, remote)
      else
        upload_file(local, File.join(remote, File.basename(local)))
      end
    end

    def shutdown
      return if @session.nil?
      logger.debug("[WinRM] closing connection to #{self}")
      # No needed as WinRM automatically open/close the shell.
      # => https://github.com/WinRb/WinRM/blob/master/lib/winrm/winrm_service.rb L205
    ensure
      @session = nil
    end

    def wait
      logger.info("Waiting for #{username}@#{hostname}:#{port}...") until test_winrm
    end

    def login_command(vagrant_root)
      LoginCommand.new("cd #{vagrant_root};vagrant rdp")
    end

    private

    attr_reader :hostname, :username, :options, :logger

    def session
      @session ||= establish_connection
    end

    def human_err_msg(msg)
      return msg unless msg.include?("CLIXML")
      human = msg.split(/<S S=\"Error\">/).map! do |a|
        a.gsub(/_x000D__x000A_<\/S>/, "")
      end
      human.shift
      human.pop
      human.join("\n")
    end

    def establish_connection
      rescue_exceptions = [
        Errno::EACCES, Errno::EADDRINUSE, Errno::ECONNREFUSED,
        Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EHOSTUNREACH,
        ::WinRM::WinRMHTTPTransportError, ::WinRM::WinRMAuthorizationError
      ]
      retries = 3

      begin
        logger.debug("[WinRM] opening connection to #{self}")
        socket = ::WinRM::WinRMWebService.new(*build_winrm_options)
        socket.set_timeout(timeout_in_seconds)
        socket
      rescue *rescue_exceptions => e
        if (retries -= 1) > 0
          logger.info("[WinRM] connection failed, retrying (#{e.inspect})")
          sleep 1
          retry
        else
          logger.warn("[WinRM] connection failed, terminating (#{e.inspect})")
          raise
        end
      end
    end

    def to_s
      "#{endpoint}@#{username}<#{options.inspect}>"
    end

    # Uploads the given file, but only if the target file doesn't exist
    # or its MD5 checksum doens't match the host's source checksum.
    #
    # @param [String] The source file path on the host
    # @param [String] The destination file path on the guest
    def upload_file(local, remote)
      if should_upload_file?(local, remote)
        tmp_file_path = upload_to_temp_file(local)
        decode_temp_file(tmp_file_path, remote)
      else
        logger.debug("Up to date: #{remote}")
      end
    end

    def endpoint
      "http://#{@hostname}:#{port}/wsman"
    end

    # Checks to see if the target file on the guest is missing or out of date.
    #
    # @param [String] The source file path on the host
    # @param [String] The destination file path on the guest
    # @return [Boolean] True if the file is missing or out of date
    def should_upload_file?(local, remote)
      local_md5 = Digest::MD5.file(local).hexdigest
      cmd = <<-EOH
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
      powershell(cmd)[:exitcode] == 1
    end

    def port
      options.fetch(:port, 5985)
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

    def timeout_in_seconds
      options.fetch(:timeout_in_seconds, 1800)
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

    def build_winrm_options
      opts = Hash.new

      opts[:user] = username
      opts[:pass] = options[:password] if options[:password]
      opts[:host] = hostname
      opts[:port] = port
      opts[:operation_timeout] = timeout_in_seconds
      opts[:basic_auth_only] = true

      [endpoint, :plaintext, opts]
    end

    def execute_shell(command, shell = :powershell)
      raise WinRMFailed, :shell => shell unless [:powershell, :cmd, :wql].include?(shell)
      begin
        shell_with_exit(command, shell)
      rescue => e
        raise WinRMFailed,
          :user => username,
          :endpoint => endpoint,
          :message => e.message,
          :shell => shell,
          :command => command
      end
    end

    def shell_with_exit(command, shell)
      winrm_err = []
      logger.debug("[WinRM] #{shell} executing:\n#{command}")
      output = session.send(shell, command) do |stdout, stderr|
        logger << stdout if stdout
        winrm_err << stderr if stderr
      end
      logger.debug("Output: #{output.inspect}")
      [output[:exitcode], winrm_err]
    end

    def run_shell(command, shell)
      raise WinRMFailed, :shell => shell unless [:powershell, :cmd, :wql].include?(shell)
      logger.debug("[WinRM] #{shell} running:\n#{command}")
      begin
        session.send(shell, command)
      rescue => e
        raise WinRMFailed,
          :user => username,
          :endpoint => endpoint,
          :message => e.message,
          :shell => shell,
          :command => command
      end
    end

    def raise_upload_error_if_failed(output, from, to)
      raise WinRMFailed,
        :from => from,
        :to => to,
        :message => output.inspect if output[:exitcode] != 0
    end

    def test_winrm
      exitcode, _error_msg = shell_with_exit("Write-Host '[Server] Reachable...\n'", :powershell)
      exitcode.zero?
      rescue
      sleep 5
      false
    end

    def guest_temp_dir
      @guest_temp ||= (cmd("echo %TEMP%"))[:data][0][:stdout].chomp
    end
  end
end

# -*- encoding: utf-8 -*-
#
# Author:: Matt Wrock (<matt@mattwrock.com>)
#
# Copyright (C) 2014, Matt Wrock
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

require "io/console"
require "json"
require "kitchen/transport/winrm_file_transfer/shell"

module Kitchen
  module Transport
    module WinRMFileTransfer

      # Represents a file to be copied to the test instance
      # It maintains a winrm session to be used for all operations
      #
      # @author Matt Wrock <matt@mattwrock.com>
      class RemoteFile

        # @return [String] path to a file or directory to copy to the test instance
        attr_reader :local_path

        # @return [String] target path on test instance to copy to
        attr_reader :remote_path

        # @return [Boolean] true if the shell has been closed.
        # The remote_file cannot be used if the shell is closed.
        attr_reader :closed

        # @return [WinRMWebService] the winrm connection used for upload
        attr_reader :service

        # @return [WinRMShell] the winrm shell used for upload
        attr_reader :shell

        # Initializes a new remote file intended for uploading
        # to the test instance
        #
        # @param logger [Logger] kitchen logger for messaging output
        # @param service [WinRMWebService] an active winrm connection
        # @param local_path [String] path to a file or directory to
        # copy to the test instance
        # @param remote_path [String] target path on test instance to copy to
        def initialize(logger, service, local_path, remote_path)
          @closed = false
          @service = service
          @shell = Shell.new(logger, service)
          @local_path = local_path
          @remote_path = full_remote_path(local_path, remote_path)
          @logger = logger
          logger.debug("Creating RemoteFile of local '#{local_path}' at '#{@remote_path}'")
        ensure
          if !shell.nil?
            ObjectSpace.define_finalizer(self, self.class.finalizer(shell))
          end
        end

        # Initiaes the upload of the local_path to the remote_path. This
        # method takes a block and yields progress data that can be
        # displayed while the upload is in progress.
        #
        # @yieldparam [Fixnum] Number of bytes copied in current payload sent to the winrm endpoint
        # @yieldparam [Fixnum] The total number of bytes to be copied
        # @yieldparam [String] Path of file being copied
        # @yieldparam [String] Target path on the winrm endpoint
        def upload(&block)
          if closed
            raise TransportFailed, "This RemoteFile is closed."
          end

          if !File.exist?(local_path)
            raise TransportFailed, "Cannot find path: '#{local_path}'"
          end

          @remote_path, should_upload = powershell_batch do | builder |
            builder << resolve_remote_command
            builder << dirty_command
          end

          if should_upload == "True"
            size = upload_to_remote(&block)
          else
            size = 0
            logger.debug("Files are equal. Not copying #{local_path} to #{remote_path}")
          end
          powershell_batch { |builder| builder << create_post_upload_command }
          size
        end

        # Closes the winrm shell used to upload the files. Note: this keeps the
        # connection open which can run multiple shells.
        def close
          shell.close unless shell.nil? || closed
          @closed = true
        end

        protected

        attr_reader :logger

        def self.finalizer(shell)
          proc { shell.close }
        end

        def full_remote_path(local_path, remote_path)
          base_file_name = File.basename(local_path)
          if File.basename(remote_path) != base_file_name
            remote_path = File.join(remote_path, base_file_name)
          end
          remote_path
        end

        def resolve_remote_command
          <<-EOH
            $sessionPath = $ExecutionContext.SessionState.Path
            $dest_file_path = $sessionPath.GetUnresolvedProviderPathFromPSPath("#{remote_path}")

            if (!(Test-Path $dest_file_path)) {
              $dest_dir = ([System.IO.Path]::GetDirectoryName($dest_file_path))
              New-Item -ItemType directory -Force -Path $dest_dir | Out-Null
            }

            $dest_file_path
          EOH
        end

        def dirty_command
          local_md5 = Digest::MD5.file(local_path).hexdigest
          <<-EOH
            $sessionPath = $ExecutionContext.SessionState.Path
            $dest_file_path = $sessionPath.GetUnresolvedProviderPathFromPSPath("#{remote_path}")

            if (Test-Path $dest_file_path) {
              $crypto = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
              try {
                $file = [System.IO.File]::Open($dest_file_path,
                  [System.IO.Filemode]::Open, [System.IO.FileAccess]::Read)
                $guest_md5 = ([System.BitConverter]::ToString($crypto.ComputeHash($file)))
                $guest_md5 = $guest_md5.Replace("-","").ToLower()
              }
              finally { $file.Dispose() }
              if ($guest_md5 -eq '#{local_md5}') { return $false }
            }
            if(Test-Path $dest_file_path){remove-item $dest_file_path -Force}
            return $true
          EOH
        end

        def upload_to_remote
          logger.debug("Uploading '#{local_path}' to temp file '#{remote_path}'")
          base64_host_file = Base64.encode64(IO.binread(local_path)).gsub("\n", "")
          base64_array = base64_host_file.chars.to_a
          bytes_copied = 0
          base64_array.each_slice(8000 - remote_path.size) do |chunk|
            shell.cmd("echo #{chunk.join} >> \"#{remote_path}\"")
            bytes_copied += chunk.count
            logger.debug("Uploading #{bytes_copied} bytes of #{base64_array.count}")
            yield bytes_copied, base64_array.count, local_path, remote_path if block_given?
          end
          base64_array.length
        end

        def decode_command
          <<-EOH
            $base64_string = Get-Content '#{remote_path}'
            try {
              $bytes = [System.Convert]::FromBase64String($base64_string)
              if($bytes -ne $null){
                [System.IO.File]::WriteAllBytes('#{remote_path}', $bytes) | Out-Null
              }
            }
            catch{}
          EOH
        end

        def create_post_upload_command
          [decode_command]
        end

        def powershell_batch
          ps_builder = []
          yield ps_builder

          commands = ["$result = @()"]
          ps_builder.flatten.each do |cmd_item|
            commands << "$result += Invoke-Command { #{cmd_item} }"
          end
          commands <<  <<-EOH
            "{"; $result | % { ++$idx;write-output "`"$idx`": `"$_`",".Replace('\\','\\\\') }; "}"
          EOH

          parse_batch_result(shell.powershell(commands.join("\n")).gsub(",\r\n}", "\n}"))
        end

        def parse_batch_result(batch_result)
          result = []
          begin
            logger.debug("parsing: #{batch_result}")
            result_hash = JSON.parse(batch_result)
            result_hash.keys.sort.each do |key|
              logger.debug("result key: #{key} is '#{result_hash[key]}'")
              result << result_hash[key] unless result_hash[key].nil?
            end
          rescue TransportFailed => tf
            raise TransportFailed,
              :from => local_path,
              :to => remote_path,
              :message => tf.message
          end
          result unless result.empty?
        end
      end
    end
  end
end

require 'io/console'
require 'json'
require 'kitchen/transport/winrm_file_transfer/shell'

module Kitchen
  module Transport
    module WinRMFileTransfer

      # Represents a file to be copied to the test instance
      # It maintains a winrm session to be used for all operations
      class RemoteFile

        attr_reader :local_path
        attr_reader :remote_path
        attr_reader :closed
        attr_reader :options
        attr_reader :service
        attr_reader :shell

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
            ObjectSpace.define_finalizer( self, self.class.close(shell) )
          end
        end

        def upload(&block)
          if closed
            raise TransportFailed.new("This RemoteFile is closed.")
          end

          if !File.exist?(local_path)
            raise TransportFailed.new("Cannot find path: '#{local_path}'")
          end

          @remote_path, should_upload = powershell_batch do | builder |
            builder << resolve_remote_command
            builder << is_dirty_command
          end

          if should_upload == 'True'
            size = upload_to_remote(&block)
          else
            size = 0
            logger.debug("Files are equal. Not copying #{local_path} to #{remote_path}")
          end
          powershell_batch {|builder| builder << create_post_upload_command}
          size
        end

        def close
          shell.close unless shell.nil? or closed
          @closed = true
        end

        protected

        attr_reader :logger

        def self.close(shell)
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

        def is_dirty_command
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
              finally {
                $file.Dispose()
              }
              if ($guest_md5 -eq '#{local_md5}') {
                return $false
              }
            }
            if(Test-Path $dest_file_path){remove-item $dest_file_path -Force}
            return $true
          EOH
        end

        def upload_to_remote(&block)
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

        def powershell_batch(&block)
          ps_builder = []
          yield ps_builder

          commands = [ "$result = @{}" ]
          idx = 0
          ps_builder.flatten.each do |cmd_item|
            commands << <<-EOH
              $result.ret#{idx} = Invoke-Command { #{cmd_item} }
            EOH
            idx += 1
          end
          commands <<  <<-EOH
            "{"
            $result.keys | % {
              write-output "`"$_`": `"$($result[$_])`",".Replace('\\','\\\\')
            }
            "}"
          EOH
          result = []
          begin
            result_hash = JSON.parse(shell.powershell(commands.join("\n")).gsub(",\r\n}","\n}"))
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
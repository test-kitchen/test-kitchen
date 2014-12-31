require 'zip'

module Kitchen
  module Transport
    module WinRMFileTransfer

      # A zip file containing a directory to upload to the test instance
      class RemoteZipFile < RemoteFile

        attr_reader :archive

        def initialize(logger, service, remote_path)
          @archive = create_archive(remote_path)
          @unzip_remote_path = remote_path
          remote_path = "$env:temp/WinRM_ft"
          super(logger, service, @archive, remote_path)
        end

        def add_file(path)
          path = path.gsub("\\","/")
          logger.debug("adding '#{path}' to zip file")
          raise TransportFailed.new("Cannot find path: '#{path}'") unless File.exist?(path)
          File.directory?(path) ? glob = File.join(path, "**/*") : glob = path
          logger.debug("iterating files in '#{glob}'")
          Zip::File.open(archive, 'w') do |zipfile|
            Dir.glob(glob).each do |file|
              logger.debug("adding zip entry for '#{file}'")
              entry = Zip::Entry.new(
                archive, 
                file.sub(File.dirname(path)+'/',''), 
                nil, nil, nil, nil, nil, nil, 
                ::Zip::DOSTime.new(2000)
              )
              zipfile.add(entry,file)
            end
          end
        end

        protected

        def create_post_upload_command
          super << extract_zip_command
        end

        private

        def create_archive(remote_path)
          temp_dir = ENV['TMP'] || ENV['TMPDIR'] || '/tmp'
          archive_folder = File.join(temp_dir, 'WinRM_file_transfer_local')
          Dir.mkdir(archive_folder) unless File.exist?(archive_folder)
          archive = File.join(archive_folder,File.basename(remote_path))+'.zip'
          FileUtils.rm archive, :force=>true

          archive
        end

        def extract_zip_command
          <<-EOH
            $sessionPath = $ExecutionContext.SessionState.Path
            $dest = $sessionPath.GetUnresolvedProviderPathFromPSPath("#{@unzip_remote_path}")
            $shellApplication = new-object -com shell.application

            $zipPackage = $shellApplication.NameSpace('#{remote_path}')
            mkdir $dest -ErrorAction SilentlyContinue | Out-Null
            $destinationFolder = $shellApplication.NameSpace($dest)
            $destinationFolder.CopyHere($zipPackage.Items(),0x10) | Out-Null
          EOH
        end
      end
    end
  end
end
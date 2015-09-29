# -*- encoding: utf-8 -*-
#
# Author:: Peter Smith (<peter@petersmith.net>)
#
# Copyright (C) 2015, Peter Smith.
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

require "kitchen"
require "kitchen/tgz"
require "kitchen/transport/ssh"

require "net/ssh"
require "net/scp"
require "pathname"

module Kitchen
  module Transport
    #
    # A Transport which uses the SSH protocol to execute commands and transfer files.
    # In addition, files are tar-gzipped to improve performance over high-latency
    # network links.
    #
    # Most of this class reuses functionality from the base Ssh class.
    #
    # @author Peter Smith <peter@petersmith.net>
    #
    class SshTgz < Kitchen::Transport::Ssh

      #
      # Manage a connection for the SshTgz transport mechanism. This is essentially
      # the same as for the Ssh::Connection class, except we compress before
      # uploading.
      #
      class Connection < Kitchen::Transport::Ssh::Connection

        # (see Ssh::Connection#upload)
        def upload(locals, remote)
          # attempt tar-gzip upload, to improve performance.
          return if Array(locals).empty? || upload_via_tgz(Array(locals), remote)

          # if tgz upload fails (e.g. not supported on target platform), fall back to
          # file-by-file upload.
          logger.warn("Tgz upload failed. Resorting to file-by-file upload.")
          super
        end

        private

        #
        # Upload a set of files onto the remote machine. Rather than uploading
        # file by file, we first package all files into a tar-gzip file (.tgz)
        # and send a single file. This avoids the slow file-copy time we'd
        # otherwise see over a high-latency network.
        #
        # @param locals [Array<String>] array of path names for each of the files to
        #   be included.
        # @param remote [String] directory on the remote host into which the files will
        #   be uploaded.
        # @return [true, false] true on success, else false.
        #
        def upload_via_tgz(locals, remote)
          # tar-gzip all the input files into a single .tgz file.
          tgz = create_tgz_file(locals)

          # upload the tar-gzip file to the remote server.
          session.scp.upload!(tgz.path, "#{remote}/kitchen.tgz", {}) do |_ch, name, sent, total|
            logger.debug("Uploaded #{name} (#{total} bytes)") if sent == total
          end

          # extract the tar-gzip file, on the remote, into individual files.
          untar_file_on_remote(remote)
          File.unlink(tgz.path)

          # indicate success - the files extracted correctly and won't need to be
          # uploaded individually.
          true
        rescue => e
          # on any failure, return false to indicate that upload via tgz failed and we
          # should default to copying individual files.
          logger.debug(".tgz upload failed. Reason: #{e}")
          false
        end

        #
        # Create a single tar-gzipped file, containing all of the individual files.
        #
        # @param locals [Array<String>] array of path names for each of the files to
        #   be included.
        # @return [Kitchen::Tgz] the Tgz object, representing the tar-gzip file we created.
        #
        def create_tgz_file(locals)
          tgz = Kitchen::Tgz.new
          locals.each do |local|
            pathname = Pathname.new(local)
            tgz.add_files(pathname.dirname.to_s, [pathname.basename.to_s])
          end
          tgz.close
          tgz
        end

        #
        # Untar the tgz file on the remote.
        #
        # @param remote [String] file system directory on remote host into which
        #   the tar-gzip file was uploaded uploaded.
        # @raise [Kitchen::SSHFailed] if the untar fails for some reason.
        #
        def untar_file_on_remote(remote)
          cmd = "tar -C #{remote} -xmzf #{remote}/kitchen.tgz"
          session.exec!(cmd) do |_ch, stream, data|
            raise SSHFailed, "Unable to untar files on remote: #{data}" if stream == :stderr
          end
        end
      end

      # (see Ssh#create_new_connection)
      def create_new_connection(options, &block)
        if @connection
          logger.debug("[SSH] shutting previous connection #{@connection}")
          @connection.close
        end

        @connection_options = options
        @connection = Kitchen::Transport::SshTgz::Connection.new(options, &block)
      end
    end
  end
end

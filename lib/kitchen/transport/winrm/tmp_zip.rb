# -*- encoding: utf-8 -*-
#
# Author:: Fletcher (<fnichol@nichol.ca>)
#
# Copyright (C) 2015, Fletcher Nichol
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

require "delegate"
require "pathname"
require "tempfile"
require "zip"

require "kitchen/transport/winrm/logging"

module Kitchen

  module Transport

    class Winrm < Kitchen::Transport::Base

      # A temporary Zip file for a given directory.
      #
      # @author Fletcher Nichol <fnichol@nichol.ca>
      class TmpZip

        include Logging

        # Contructs a new Zip file for the given directory.
        #
        # There are 2 ways to interpret the directory path:
        #
        # * If the directory has no path separator terminator, then the
        #   directory basename will be used as the base directory in the
        #   resulting zip file.
        # * If the directory has a path separator terminator (such as `/` or
        #   `\\`), then the entries under the directory will be added to the
        #   resulting zip file.
        #
        # The following emaples assume a directory tree structure of:
        #
        #     src
        #     |-- alpha.txt
        #     |-- beta.txt
        #     \-- sub
        #         \-- charlie.txt
        #
        # @example Including the base directory in the zip file
        #
        #   TmpZip.new("/path/to/src")
        #   # produces a zip file with entries:
        #   # - src/alpha.txt
        #   # - src/beta.txt
        #   # - src/sub/charlie.txt
        #
        # @example Excluding the base directory in the zip file
        #
        #   TmpZip.new("/path/to/src/")
        #   # produces a zip file with entries:
        #   # - alpha.txt
        #   # - beta.txt
        #   # - sub/charlie.txt
        #
        # @param dir [String,Pathname,#to_s] path to the directory
        # @param logger [#debug,#debug?] an optional logger/ui object that
        #   responds to `#debug` and `#debug?` (default `nil`)
        def initialize(dir, logger = nil)
          @logger = logger
          @dir = Pathname.new(dir)
          @method = ::Zip::Entry::DEFLATED
          @compression = Zlib::BEST_COMPRESSION
          @zip_io = Tempfile.open(["tmpzip-", ".zip"], :binmode => true)
          write_zip
          @zip_io.close
        end

        # @return [Pathname] path to zip file
        def path
          Pathname.new(zip_io.path) if zip_io.path
        end

        # Unlinks (deletes) the zip file from the filesystem.
        def unlink
          zip_io.unlink
        end

        private

        # @return [Integer] the compression used for Zip entries. Possible
        #   values are `Zlib::BEST_COMPRESSION`, `Zlib::DEFAULT_COMPRESSION`,
        #   and `Zlib::NO_COMPRESSION`.
        # @api private
        attr_reader :compression

        # @return [Pathname] the directory used to create the Zip file
        # @api private
        attr_reader :dir

        # @return [#debug] the logger
        # @api private
        attr_reader :logger

        # @return [Integer] compression method used for Zip entries. Possible
        #   values are `Zip::Entry::DEFLATED` and `Zip::Entry::STORED`.
        # @api private
        attr_reader :method

        # @return [IO] the Zip file IO
        # @api private
        attr_reader :zip_io

        # @return [Pathname] the path segement to be stripped off Zip entries
        # @api private
        def dir_strip
          @dir_strip ||= if dir.to_s.end_with?("/", "\\")
            Pathname.new(dir.to_s.chop)
          else
            dir.dirname
          end
        end

        # @return [Array<Pathname] all recursive files under the base
        #   directory, excluding directories
        # @api private
        def entries
          Pathname.glob(dir.join("**/*")).delete_if(&:directory?).sort
        end

        # (see Logging.log_subject)
        # @api private
        def log_subject
          @log_subject ||= [self.class.to_s.split("::").last, path].join("::")
        end

        # Adds all file entries to the Zip output stream.
        #
        # @param zos [Zip::OutputStream] zip output stream
        # @api private
        def produce_zip_entries(zos)
          entries.each do |entry|
            entry_path = entry.sub("#{dir_strip}/", "")
            debug { "+++ Adding #{entry_path}" }
            zos.put_next_entry(entry_path, nil, nil, method, compression)
            entry.open("rb") { |src| IO.copy_stream(src, zos) }
          end
          debug { "=== All files added." }
        end

        # Writes out a temporary Zip file.
        #
        # @api private
        def write_zip
          debug { "Populating files" }
          Zip::OutputStream.write_buffer(NoDupIO.new(zip_io)) do |zos|
            produce_zip_entries(zos)
          end
        end

        # Simple delegate wrapper to prevent `#dup` calls being made on IO
        # objects. This is used to bypass an issue in the `Zip::Outputstream`
        # constructor where an incoming IO is duplicated, leading to races
        # on flushing the final stream to disk.
        #
        # @author Fletcher Nichol <fnichol@nichol.ca>
        # @api private
        class NoDupIO < SimpleDelegator

          # @return [self] returns self and does *not* return a duplicate
          #   object
          def dup
            self
          end
        end
      end
    end
  end
end

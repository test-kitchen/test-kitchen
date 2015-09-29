# -*- encoding: utf-8 -*-
#
# Author:: Peter Smith (<peter@petersmith.net>)
#
# Copyright (C) 2015, Peter Smith
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

require "tempfile"
require "zlib"
require "rubygems/package"

module Kitchen
  #
  # Error thrown if the Tgz has an invalid format.
  #
  class GzipFormatError < StandardError; end

  #
  # Represents a Tar-Gzip file, allowing multiple files to be combined
  # into a single file. This is useful for transmitting a large number
  # of files across high-latency networks.
  #
  class Tgz
    #
    # @return [String] the file system path of the generated tar-gzip file.
    #
    attr_reader :path

    #
    # Create a new Tgz object, in preparation for adding files to the
    # tar-gzip archive.
    #
    # @param tgz_file_name [String, nil] The output file name, in
    #   tar-gzipped format. If not specified, a temporary file name will be generated.
    #
    def initialize(tgz_file_name = nil)
      if tgz_file_name
        # user-provided output file name
        @tgz_file = File.open(tgz_file_name, "wb+")
        @path = tgz_file_name
      else
        # auto-generated output file name
        @tgz_file = Tempfile.new("tgz")
        @tgz_file.binmode
        @path = @tgz_file.path
      end

      #
      # Intermediate file for writing the 'tar' content (which will then be
      # gzipped into the output 'tgz' file)
      #
      @tar_file = Tempfile.new("tar")
      @tar_file.binmode
      @tar_writer = Gem::Package::TarWriter.new(@tar_file)
    end

    #
    # Add a set of files or directories into the Tgz archive. Directories will
    # be traversed, with all files and subdirectories being added (symlinks are ignored).
    #
    # For example:
    #
    #     tgz.add_files('/home/me/my_dir', ['fileA', 'dirA/fileB'])
    #
    # @param dir [String] the directory containing the files/sub-dirs to archive.
    # @param files [Array<String>] the files/sub-directories to be added, specified
    #   relative to the containing directory (dir).
    #
    def add_files(dir, files)
      files.each do |file_name|
        full_path = "#{dir}/#{file_name}"
        next if File.symlink?(full_path)
        if File.directory?(full_path)
          add_directory_to_tar(dir, file_name, full_path)
        else
          add_file_to_tar(full_path, file_name)
        end
      end
    end

    #
    # Close the Tgz object, generating the tgz file (from the tar file), and ensuring
    # that it's flushed to disk.
    #
    def close
      # ensure tar_writer flushes everything to our temporary 'tar' file.
      @tar_writer.close

      # proceed to convert the 'tar' file into a 'tgz' file.
      @tar_file.rewind
      create_tgz_file(@tar_file, @tgz_file)
      @tar_file.close
    end

    #
    # Class-methods
    #
    class << self
      #
      # Return the original size of the uncompressed file.
      #
      # @param file_name [String] name of the compressed file, in .tgz format.
      # @return [Integer] the original (uncompressed) file's size
      # @raise [GzipFormatError] if the file is not a valid Gzip file.
      #
      def original_size(file_name)
        File.open(file_name, "r") do |file|
          # the first three bytes of a gzip file must be 0x1f, 0x8b, 0x08
          fail unless (file.readbyte == 0x1f) && (file.readbyte == 0x8b) &&
              (file.readbyte == 0x08)
          return original_file_length_field(file)
        end
      rescue
        raise GzipFormatError, "Gzip file could not be opened, or has invalid format: #{file_name}"
      end

      private

      #
      # Gzip files have their original/uncompressed length in the last 4 bytes
      # (little endian format)
      #
      def original_file_length_field(file)
        file.seek(-4, IO::SEEK_END)
        (file.readbyte) | (file.readbyte << 8) | (file.readbyte << 16) | (file.readbyte << 24)
      end
    end

    private

    #
    # Recursively traverse/add a sub-directory to the tar-gzip file.
    #
    def add_directory_to_tar(dir, file_name, full_path)
      entries = Dir.entries(full_path)
      entries.delete(".")
      entries.delete("..")
      add_files(dir, entries.map { |entry| "#{file_name}/#{entry}" })
    end

    #
    # Add a single file to the tar-gzip file.
    #
    def add_file_to_tar(full_path, file_name)
      stat = File.stat(full_path)
      @tar_writer.add_file(file_name, stat.mode) do |file|
        File.open(full_path, "rb") do |input|
          while (buff = input.read(4096))
            file.write(buff)
          end
        end
      end
    end

    #
    # The temporary tar file has been fully populated, so run the compress operation
    # to generate the final tar-gzip file.
    #
    def create_tgz_file(source_file, dest_file)
      Zlib::GzipWriter.wrap(dest_file) do |gzip_writer|
        FileUtils.copy_stream(source_file, gzip_writer)
      end
    end
  end
end

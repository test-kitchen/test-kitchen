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

require "benchmark"
require "csv"
require "digest"

require "kitchen/transport/winrm/logging"
require "kitchen/transport/winrm/template"

module Kitchen

  module Transport

    class Winrm < Kitchen::Transport::Base

      # Object which can upload one or more files or directories to a remote
      # host over WinRM using Powershell scripts and CMD commands. Note that
      # this form of file transfer is *not* ideal and extremely costly on both
      # the local and remote sides. Great pains are made to minimize round
      # trips to  the remote host and to minimize the number of Powershell
      # sessions being invoked which can be 2 orders of magnitude more
      # expensive than vanilla CMD commands.
      #
      # This object is supported by either a `WinRM::WinRMWebService` or
      # `Winrm::CommandExecutor` instance as it depends on the `#run_cmd` and
      # `#run_powershell_script` API contracts.
      #
      # An optional logger can be supplied, assuming it can respond to the
      # `#debug` and `#debug?` messages.
      #
      # @author Fletcher Nichol <fnichol@nichol.ca>
      # @author Matt Wrock <matt@mattwrock.com>
      class FileTransporter

        include Logging

        # Creates a FileTransporter given a service object and optional logger.
        # The service object may be a `WinRM::WinRMWebService` or
        # `Winrm::CommandExecutor` instance.
        #
        # @param service [WinRM::WinRMWebService,Winrm::CommandExecutor] a
        #   winrm web service object
        # @param logger [#debug,#debug?] an optional logger/ui object that
        #   responds to `#debug` and `#debug?` (default: `nil`)
        def initialize(service, logger = nil)
          @service  = service
          @logger   = logger
        end

        # Uploads a collection of files to the remote host.
        #
        # **TODO Notes:**
        # * options could specify zip mode, zip options, etc.
        # * maybe option to set tmpfile base dir to override $env:PATH?
        # * progress yields block like net-scp progress
        # * final API: def upload(locals, remote, _options = {}, &_progress)
        #
        # @param locals [Array<String>,String] one or more local file paths
        # @param remote [String] the base destination path on the remote host
        # @return [Hash] report hash, keyed by the local MD5 digest
        def upload(locals, remote)
          files = make_files_hash(Array(locals), remote)

          elapsed = Benchmark.measure do
            report = check_files(files)
            merge_with_report!(files, report)

            report = stream_upload_files(files)
            merge_with_report!(files, report)

            report = decode_files(files)
            merge_with_report!(files, report)
          end

          debug {
            "Uploaded #{files.keys.size} items " \
            "in #{Util.duration(elapsed.real)}"
          }

          files
        end

        private

        MAX_ENCODED_WRITE = 8000

        BASE64_PACK = "m0".freeze

        # @return [#debug,#debug?] the logger
        # @api private
        attr_reader :logger

        # @return [WinRM::WinRMWebService,Winrm::CommandExecutor] a WinRM web
        #   service object
        # @api private
        attr_reader :service

        # Runs the check_files Powershell script against a collection of
        # destination path/MD5 checksum pairs. The Powershell script returns
        # its results as a CSV-formatted report which is converted into a Ruby
        # Hash.
        #
        # @param files [Hash] files hash, keyed by the local MD5 digest
        # @return [Hash] a report hash, keyed by the local MD5 digest
        # @api private
        def check_files(files)
          debug { "Running check_files.ps1" }
          output = service.run_powershell_script(
            check_files_template % { :files => check_files_ps_hash(files) }
          )
          parse_response(output)
        end

        # Constructs a collection of destination path/MD5 checksum pairs as a
        # String representation of the contents of a Powershell Hash Table.
        #
        # @param files [Hash] files hash, keyed by the local MD5 digest
        # @return [String] the inner contents of a Powershell Hash Table
        # @api private
        def check_files_ps_hash(files)
          files.map { |md5, paths| %{"#{paths["dst"]}" = "#{md5}"} }.join("; ")
        end

        # @return [Template] an un-rendered template of the check_files
        #   Powershell script
        # @api private
        def check_files_template
          @check_files_template ||= Template.new(File.join(
            File.dirname(__FILE__),
            %W[.. .. .. .. support check_files.ps1.erb]
          ))
        end

        # Runs the decode_files Powershell script against a collection of
        # temporary file/destination path pairs. The Powershell script returns
        # its results as a CSV-formatted report which is converted into a Ruby
        # Hash. The script will not be invoked if there are no "dirty" files
        # present in the incoming files Hash.
        #
        # @param files [Hash] files hash, keyed by the local MD5 digest
        # @return [Hash] a report hash, keyed by the local MD5 digest
        # @api private
        def decode_files(files)
          decoded_files = decode_files_ps_hash(files)

          if decoded_files.empty?
            debug { "No remote files to decode, skipping" }
            Hash.new
          else
            debug { "Running decode_files.ps1" }
            output = service.run_powershell_script(
              decode_files_template % { :files => decoded_files }
            )
            parse_response(output)
          end
        end

        # Constructs a collection of temporary file/destination path pairs for
        # all "dirty" files as a String representation of the contents of a
        # Powershell Hash Table. A "dirty" file is one which has the
        # `"chk_dirty"` option set to `"True"` in the incoming files Hash.
        #
        # @param files [Hash] files hash, keyed by the local MD5 digest
        # @return [String] the inner contents of a Powershell Hash Table
        # @api private
        def decode_files_ps_hash(files)
          files.select { |_, data| data["chk_dirty"] == "True" }.
            map { |_, data| %{"#{data["tmpfile"]}" = "#{data["dst"]}"} }.
            join("; ")
        end

        # @return [Template] an un-rendered template of the decode_files
        #   Powershell script
        # @api private
        def decode_files_template
          @decode_files_template ||= Template.new(File.join(
            File.dirname(__FILE__),
            %W[.. .. .. .. support decode_files.ps1.erb]
          ))
        end

        # Contructs a Hash of files, keyed by the local MD5 digest. Each file
        # entry has a source and destination set, at a minimum.
        #
        # @param locals [Array<String>] a collection of local files
        # @param remote [String] the base destination path on the remote host
        # @return [Hash] files hash, keyed by the local MD5 digest
        # @api private
        def make_files_hash(locals, remote)
          hash = Hash.new
          locals.each do |local|
            local = File.expand_path(local)
            raise "No file #{local} found" unless File.file?(local)

            hash[md5sum(local)] = {
              "src"   => local,
              "dst"   => "#{remote}\\#{File.basename(local)}",
              "size"  => File.size(local)
            }
          end
          hash
        end

        # @return [String] the MD5 digest of a local file
        # @api private
        def md5sum(local)
          Digest::MD5.file(local).hexdigest
        end

        # Destructively merges a report Hash into an existing files Hash.
        # **Note:** this method mutates the files Hash.
        #
        # @param files [Hash] files hash, keyed by the local MD5 digest
        # @param report [Hash] report hash, keyed by the local MD5 digest
        # @api private
        def merge_with_report!(files, report)
          files.merge!(report) { |_, oldval, newval| oldval.merge(newval) }
        end

        # Parses response of a Powershell script or CMD command which contains
        # a CSV-formatted document in the standard output stream.
        #
        # @param output [WinRM::Output] output object with stdout, stderr, and
        #   exit code
        # @return [Hash] report hash, keyed by the local MD5 digest
        # @api private
        def parse_response(output)
          array = CSV.parse(output.stdout, :headers => true).map(&:to_hash)
          Hash[array.map { |entry| [entry.fetch("src_md5"), entry] }]
        end

        # Uploads an IO stream to a Base64-encoded destination file.
        #
        # **Implementation Note:** Some of the code in this method may appear
        # slightly too dense and while adding additional variables would help,
        # the code is written very precisely to avoid unwanted allocations
        # which will bloat the Ruby VM's object space (and memory footprint).
        # The goal here is to stream potentially large files to a remote host
        # while not loading the entire file into memory first, then Base64
        # encoding it--duplicating the file in memory again.
        #
        # @param input_io [#read] a readable stream or object to be uploaded
        # @param dest [String] path to the destination file on the remote host
        # @return [Integer,Integer] the number of resulting upload chunks and
        #   the number of bytes transferred to the remote host
        # @api private
        def stream_upload(input_io, dest)
          dest_cmd = dest.sub("$env:TEMP", "%TEMP%")
          read_size = (MAX_ENCODED_WRITE.to_i / 4) * 3
          chunk, bytes = 1, 0
          buffer = ""
          service.run_cmd(%{echo|set /p=>"#{dest_cmd}"}) # truncate empty file
          while input_io.read(read_size, buffer)
            bytes += (buffer.bytesize / 3 * 4)
            service.run_cmd([buffer].pack(BASE64_PACK).
              insert(0, "echo ").concat(%{ >> "#{dest_cmd}"}))
            debug { "Wrote chunk #{chunk} for #{dest}" } if chunk % 25 == 0
            chunk += 1
          end
          buffer = nil # rubocop:disable Lint/UselessAssignment

          [chunk - 1, bytes]
        end

        # Uploads a local file to a Base64-encoded temporary file.
        #
        # @param src [String] path to a local file
        # @param tmpfile [String] path to the temporary file on the remote
        #   host
        # @return [Integer,Integer] the number of resulting upload chunks and
        #   the number of bytes transferred to the remote host
        # @api private
        def stream_upload_file(src, tmpfile)
          debug { "Uploading #{src} to encoded tmpfile #{tmpfile}" }
          chunks, bytes = 0, 0
          elapsed = Benchmark.measure do
            File.open(src, "rb") do |io|
              chunks, bytes = stream_upload(io, tmpfile)
            end
          end
          debug {
            "Finished uploading #{src} to encoded tmpfile #{tmpfile} " \
            "(#{bytes.to_f / 1000} KB over #{chunks} chunks) " \
            "in #{Util.duration(elapsed.real)}"
          }

          [chunks, bytes]
        end

        # Uploads a collection of "dirty" files to the remote host as
        # Base64-encoded temporary files. A "dirty" file is one which has the
        # `"chk_dirty"` option set to `"True"` in the incoming files Hash.
        #
        # @param files [Hash] files hash, keyed by the local MD5 digest
        # @return [Hash] a report hash, keyed by the local MD5 digest
        # @api private
        def stream_upload_files(files)
          response = Hash.new
          files.each do |md5, data|
            if data["chk_dirty"] == "True"
              tmpfile = "$env:TEMP\\b64-#{md5}.txt"
              response[md5] = { "tmpfile" => tmpfile }
              chunks, bytes = stream_upload_file(data["src"], tmpfile)
              response[md5]["chunks"] = chunks
              response[md5]["xfered"] = bytes
            else
              debug { "File #{data["dst"]} is up to date, skipping" }
            end
          end
          response
        end
      end
    end
  end
end

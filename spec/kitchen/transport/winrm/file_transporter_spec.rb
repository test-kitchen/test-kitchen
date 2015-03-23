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

require_relative "../../../spec_helper"

require "base64"
require "csv"
require "stringio"
require "logger"
require "winrm"

require "kitchen"
require "kitchen/transport/winrm/file_transporter"

describe Kitchen::Transport::Winrm::FileTransporter do

  CheckEntry = Struct.new(
    :chk_exists, :src_md5, :dst_md5, :chk_dirty, :verifies)
  DecodeEntry = Struct.new(
    :dst, :verifies, :src_md5, :dst_md5, :tmpfile, :tmpzip)

  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }

  let(:randomness)    { %W[alpha beta charlie delta].each }
  let(:id_generator)  { -> { randomness.next } }

  let(:service) do
    s = mock("winrm_service")
    s.responds_like_instance_of(WinRM::WinRMWebService)
    s
  end

  let(:transporter) do
    Kitchen::Transport::Winrm::FileTransporter.new(
      service,
      logger,
      :id_generator => id_generator
    )
  end

  before { @tempfiles = [] }

  after { @tempfiles.each(&:unlink) }

  describe "when uploading a single file" do

    let(:content)     { "." * 12003 }
    let(:local)       { create_tempfile("input.txt", content) }
    let(:remote)      { "C:\\dest" }
    let(:dst)         { "#{remote}\\#{File.basename(local)}" }
    let(:src_md5)     { md5sum(local) }
    let(:size)        { File.size(local) }
    let(:cmd_tmpfile) { "%TEMP%\\b64-#{src_md5}.txt" }
    let(:ps_tmpfile)  { "$env:TEMP\\b64-#{src_md5}.txt" }

    let(:upload) { transporter.upload(local, remote) }

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def self.common_specs_for_all_single_file_types
      it "truncates a zero-byte hash_file for check_files" do
        service.expects(:run_cmd).with { |cmd, *_|
          cmd =~ regexify(%{echo|set /p=>"%TEMP%\\hash-alpha.txt"})
        }.returns(cmd_output)

        upload
      end

      it "uploads the hash_file in chunks for check_files" do
        hash = Kitchen::Util.outdent!(<<-HASH.chomp)
          @{
            "#{dst}" = "#{src_md5}"
          }
        HASH

        service.expects(:run_cmd).
          with(%{echo #{base64(hash)} >> "%TEMP%\\hash-alpha.txt"}).
          returns(cmd_output).times(1)

        upload
      end

      it "sets hash_file and runs the check_files powershell script" do
        service.expects(:run_powershell_script).with { |script|
          script =~ regexify(%{$hash_file = "$env:TEMP\\hash-alpha.txt"}) &&
            script =~ regexify(
              "Check-Files (Invoke-Input $hash_file) | " \
              "ConvertTo-Csv -NoTypeInformation")
        }.returns(check_output)

        upload
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def self.common_specs_for_all_single_dirty_file_types
      it "truncates a zero-byte tempfile" do
        service.expects(:run_cmd).with { |cmd, *_|
          cmd =~ regexify(%{echo|set /p=>"#{cmd_tmpfile}"})
        }.returns(cmd_output)

        upload
      end

      it "uploads the file in 8k chunks" do
        service.expects(:run_cmd).
          with(%{echo #{base64("." * 6000)} >> "#{cmd_tmpfile}"}).
          returns(cmd_output).times(2)
        service.expects(:run_cmd).
          with(%{echo #{base64("." * 3)} >> "#{cmd_tmpfile}"}).
          returns(cmd_output).times(1)

        upload
      end

      describe "with a small file" do

        let(:content) { "hello, world" }

        it "uploads the file in base64 encoding" do
          service.expects(:run_cmd).
            with(%{echo #{base64(content)} >> "#{cmd_tmpfile}"}).
            returns(cmd_output)

          upload
        end
      end

      it "truncates a zero-byte hash_file for decode_files" do
        service.expects(:run_cmd).with { |cmd, *_|
          cmd =~ regexify(%{echo|set /p=>"%TEMP%\\hash-beta.txt"})
        }.returns(cmd_output)

        upload
      end

      it "uploads the hash_file in chunks for decode_files" do
        hash = Kitchen::Util.outdent!(<<-HASH.chomp)
          @{
            "#{ps_tmpfile}" = @{
              "dst" = "#{dst}"
            }
          }
        HASH

        service.expects(:run_cmd).
          with(%{echo #{base64(hash)} >> "%TEMP%\\hash-beta.txt"}).
          returns(cmd_output).times(1)

        upload
      end

      it "sets hash_file and runs the decode_files powershell script" do
        service.expects(:run_powershell_script).with { |script|
          script =~ regexify(%{$hash_file = "$env:TEMP\\hash-beta.txt"}) &&
            script =~ regexify(
              "Decode-Files (Invoke-Input $hash_file) | " \
              "ConvertTo-Csv -NoTypeInformation")
        }.returns(check_output)

        upload
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    describe "for a new file" do

      # let(:check_output) do
      def check_output
        create_check_output([
          CheckEntry.new("False", src_md5, nil, "True", "False")
        ])
      end

      let(:cmd_output) do
        o = WinRM::Output.new
        o[:exitcode] = 0
        o
      end

      # let(:decode_output) do
      def decode_output
        create_decode_output([
          DecodeEntry.new(dst, "True", src_md5, src_md5, ps_tmpfile, nil)
        ])
      end

      before do
        service.stubs(:run_cmd).
          returns(cmd_output)

        service.stubs(:run_powershell_script).
          with { |script| script =~ /^Check-Files .+ \| ConvertTo-Csv/ }.
          returns(check_output)

        service.stubs(:run_powershell_script).
          with { |script| script =~ /^Decode-Files .+ \| ConvertTo-Csv/ }.
          returns(decode_output)
      end

      common_specs_for_all_single_file_types

      common_specs_for_all_single_dirty_file_types

      it "returns a report hash" do
        upload.must_equal(
          src_md5 => {
            "src"         => local,
            "dst"         => dst,
            "tmpfile"     => ps_tmpfile,
            "tmpzip"      => nil,
            "src_md5"     => src_md5,
            "dst_md5"     => src_md5,
            "chk_exists"  => "False",
            "chk_dirty"   => "True",
            "verifies"    => "True",
            "size"        => size,
            "xfered"      => size / 3 * 4,
            "chunks"      => (size / 6000.to_f).ceil
          }
        )
      end

      describe "when a failed check command is returned" do

        def check_output
          o = WinRM::Output.new
          o[:exitcode] = 10
          o[:data].concat([{ :stderr => "Oh noes\n" }])
          o
        end

        it "raises a FileTransporterFailed error" do
          err = proc {
            upload
          }.must_raise Kitchen::Transport::Winrm::FileTransporterFailed
          err.message.must_match regexify(
            "Upload failed (exitcode: 10)", :partial_line)
        end
      end

      describe "when a failed decode command is returned" do

        def decode_output
          o = WinRM::Output.new
          o[:exitcode] = 10
          o[:data].concat([{ :stderr => "Oh noes\n" }])
          o
        end

        it "raises a FileTransporterFailed error" do
          err = proc {
            upload
          }.must_raise Kitchen::Transport::Winrm::FileTransporterFailed
          err.message.must_match regexify(
            "Upload failed (exitcode: 10)", :partial_line)
        end
      end
    end

    describe "for an out of date (dirty) file" do

      let(:check_output) do
        create_check_output([
          CheckEntry.new("True", src_md5, "aabbcc", "True", "False")
        ])
      end

      let(:cmd_output) do
        o = WinRM::Output.new
        o[:exitcode] = 0
        o
      end

      let(:decode_output) do
        create_decode_output([
          DecodeEntry.new(dst, "True", src_md5, src_md5, ps_tmpfile, nil)
        ])
      end

      before do
        service.stubs(:run_cmd).
          returns(cmd_output)

        service.stubs(:run_powershell_script).
          with { |script| script =~ /^Check-Files .+ \| ConvertTo-Csv/ }.
          returns(check_output)

        service.stubs(:run_powershell_script).
          with { |script| script =~ /^Decode-Files .+ \| ConvertTo-Csv/ }.
          returns(decode_output)
      end

      common_specs_for_all_single_file_types

      common_specs_for_all_single_dirty_file_types

      it "returns a report hash" do
        upload.must_equal(
          src_md5 => {
            "src"         => local,
            "dst"         => dst,
            "tmpfile"     => ps_tmpfile,
            "tmpzip"      => nil,
            "src_md5"     => src_md5,
            "dst_md5"     => src_md5,
            "chk_exists"  => "True",
            "chk_dirty"   => "True",
            "verifies"    => "True",
            "size"        => size,
            "xfered"      => size / 3 * 4,
            "chunks"      => (size / 6000.to_f).ceil
          }
        )
      end
    end

    describe "for an up to date (clean) file" do

      let(:check_output) do
        create_check_output([
          CheckEntry.new("True", src_md5, src_md5, "False", "True")
        ])
      end

      let(:cmd_output) do
        o = WinRM::Output.new
        o[:exitcode] = 0
        o
      end

      before do
        service.stubs(:run_cmd).
          returns(cmd_output)

        service.stubs(:run_powershell_script).
          with { |script| script =~ /^Check-Files .+ \| ConvertTo-Csv/ }.
          returns(check_output)
      end

      common_specs_for_all_single_file_types

      it "uploads nothing" do
        service.expects(:run_cmd).never

        upload
      end

      it "skips the decode_files powershell script" do
        service.expects(:run_powershell_script).with { |script|
          script =~ regexify(
            "Decode-Files $files | ConvertTo-Csv -NoTypeInformation")
        }.never

        upload
      end

      it "returns a report hash" do
        upload.must_equal(
          src_md5 => {
            "src"         => local,
            "dst"         => dst,
            "size"        => size,
            "src_md5"     => src_md5,
            "dst_md5"     => src_md5,
            "chk_exists"  => "True",
            "chk_dirty"   => "False",
            "verifies"    => "True"
          }
        )
      end
    end
  end

  describe "when uploading a single directory" do

    let(:content)     { "I'm a fake zip file" }
    let(:local)       { Dir.mktmpdir("input") }
    let(:remote)      { "C:\\dest" }
    let(:src_zip)     { create_tempfile("fake.zip", content) }
    let(:dst)         { remote }
    let(:src_md5)     { md5sum(src_zip) }
    let(:size)        { File.size(src_zip) }
    let(:cmd_tmpfile) { "%TEMP%\\b64-#{src_md5}.txt" }
    let(:ps_tmpfile)  { "$env:TEMP\\b64-#{src_md5}.txt" }
    let(:ps_tmpzip)   { "$env:TEMP\\tmpzip-#{src_md5}.zip" }

    let(:tmp_zip) do
      s = mock("tmp_zip")
      s.responds_like_instance_of(Kitchen::Transport::Winrm::TmpZip)
      s.stubs(:path).returns(Pathname(src_zip))
      s.stubs(:unlink)
      s
    end

    let(:cmd_output) do
      o = WinRM::Output.new
      o[:exitcode] = 0
      o
    end

    let(:check_output) do
      create_check_output([
        CheckEntry.new("False", src_md5, nil, "True", "False")
      ])
    end

    let(:decode_output) do
      create_decode_output([
        DecodeEntry.new(dst, "True", src_md5, src_md5, ps_tmpfile, ps_tmpzip)
      ])
    end

    before do
      Kitchen::Transport::Winrm::TmpZip.stubs(:new).with("#{local}/", logger).
        returns(tmp_zip)

      service.stubs(:run_cmd).
        returns(cmd_output)

      # service.stubs(:run_cmd).with { |cmd, *_|
      #   if match = %r{^echo (\w+) >> "%TEMP%\\hash-alpha.txt"$}.match(cmd)
      #     hash = Base64.strict_decode64(match[1])
      #     zip_info[:tmpzip] = %r{"(\$env:TEMP\\tmpzip-\w+\.zip)"}.match(hash)[1]
      #     zip_info[:src_md5] = %r{tmpzip-(\w+)\.zip$}.match(zip_info[:tmpzip])[1]
      #   end
      # }.returns(cmd_output)

      service.stubs(:run_powershell_script).
        with { |script| script =~ /^Check-Files .+ \| ConvertTo-Csv/ }.
        returns(check_output)

      service.stubs(:run_powershell_script).
        with { |script| script =~ /^Decode-Files .+ \| ConvertTo-Csv/ }.
        returns(decode_output)
    end

    after do
      FileUtils.rm_rf(local)
    end

    let(:upload) { transporter.upload("#{local}/", remote) }

    it "truncates a zero-byte hash_file for check_files" do
      service.expects(:run_cmd).with { |cmd, *_|
        cmd =~ regexify(%{echo|set /p=>"%TEMP%\\hash-alpha.txt"})
      }.returns(cmd_output)

      upload
    end

    it "uploads the hash_file in chunks for check_files" do
      hash = Kitchen::Util.outdent!(<<-HASH.chomp)
        @{
          "#{ps_tmpzip}" = "#{src_md5}"
        }
      HASH

      service.expects(:run_cmd).
        with(%{echo #{base64(hash)} >> "%TEMP%\\hash-alpha.txt"}).
        returns(cmd_output).times(1)

      upload
    end

    it "sets hash_file and runs the check_files powershell script" do
      service.expects(:run_powershell_script).with { |script|
        script =~ regexify(%{$hash_file = "$env:TEMP\\hash-alpha.txt"}) &&
          script =~ regexify(
            "Check-Files (Invoke-Input $hash_file) | " \
            "ConvertTo-Csv -NoTypeInformation")
      }.returns(check_output)

      upload
    end

    it "truncates a zero-byte tempfile" do
      service.expects(:run_cmd).with { |cmd, *_|
        cmd =~ regexify(%{echo|set /p=>"#{cmd_tmpfile}"})
      }.returns(cmd_output)

      upload
    end

    it "uploads the zip file in base64 encoding" do
      service.expects(:run_cmd).
        with(%{echo #{base64(content)} >> "#{cmd_tmpfile}"}).
        returns(cmd_output)

      upload
    end

    it "truncates a zero-byte hash_file for decode_files" do
      service.expects(:run_cmd).with { |cmd, *_|
        cmd =~ regexify(%{echo|set /p=>"%TEMP%\\hash-beta.txt"})
      }.returns(cmd_output)

      upload
    end

    it "uploads the hash_file in chunks for decode_files" do
      hash = Kitchen::Util.outdent!(<<-HASH.chomp)
        @{
          "#{ps_tmpfile}" = @{
            "dst" = "#{dst}"
            "tmpzip" = "#{ps_tmpzip}"
          }
        }
      HASH

      service.expects(:run_cmd).
        with(%{echo #{base64(hash)} >> "%TEMP%\\hash-beta.txt"}).
        returns(cmd_output).times(1)

      upload
    end

    it "sets hash_file and runs the decode_files powershell script" do
      service.expects(:run_powershell_script).with { |script|
        script =~ regexify(%{$hash_file = "$env:TEMP\\hash-beta.txt"}) &&
          script =~ regexify(
            "Decode-Files (Invoke-Input $hash_file) | " \
            "ConvertTo-Csv -NoTypeInformation")
      }.returns(check_output)

      upload
    end

    it "returns a report hash" do
      upload.must_equal(
        src_md5 => {
          "src"         => "#{local}/",
          "src_zip"     => src_zip,
          "dst"         => dst,
          "tmpfile"     => ps_tmpfile,
          "tmpzip"      => ps_tmpzip,
          "src_md5"     => src_md5,
          "dst_md5"     => src_md5,
          "chk_exists"  => "False",
          "chk_dirty"   => "True",
          "verifies"    => "True",
          "size"        => size,
          "xfered"      => size / 3 * 4,
          "chunks"      => (size / 6000.to_f).ceil
        }
      )
    end

    it "cleans up the zip file" do
      tmp_zip.expects(:unlink)

      upload
    end

    describe "when a failed check command is returned" do

      def check_output
        o = WinRM::Output.new
        o[:exitcode] = 10
        o[:data].concat([{ :stderr => "Oh noes\n" }])
        o
      end

      it "raises a FileTransporterFailed error" do
        err = proc {
          upload
        }.must_raise Kitchen::Transport::Winrm::FileTransporterFailed
        err.message.must_match regexify(
          "Upload failed (exitcode: 10)", :partial_line)
      end
    end

    describe "when a failed decode command is returned" do

      def decode_output
        o = WinRM::Output.new
        o[:exitcode] = 10
        o[:data].concat([{ :stderr => "Oh noes\n" }])
        o
      end

      it "raises a FileTransporterFailed error" do
        err = proc {
          upload
        }.must_raise Kitchen::Transport::Winrm::FileTransporterFailed
        err.message.must_match regexify(
          "Upload failed (exitcode: 10)", :partial_line)
      end
    end
  end

  describe "when uploading multiple files" do

    let(:remote) { "C:\\Program Files" }

    1.upto(3).each do |i|
      let(:"local#{i}") { create_tempfile("input#{i}.txt", "input#{i}") }
      let(:"src#{i}_md5") { md5sum(send("local#{i}")) }
      let(:"dst#{i}") { "#{remote}\\#{File.basename(send("local#{i}"))}" }
      let(:"size#{i}") { File.size(send("local#{i}")) }
      let(:"cmd#{i}_tmpfile") { "%TEMP%\\b64-#{send("src#{i}_md5")}.txt" }
      let(:"ps#{i}_tmpfile") { "$env:TEMP\\b64-#{send("src#{i}_md5")}.txt" }
    end

    let(:check_output) do
      create_check_output([
        # new
        CheckEntry.new("False", src1_md5, nil, "True", "False"),
        # out-of-date
        CheckEntry.new("True", src2_md5, "aabbcc", "True", "False"),
        # current
        CheckEntry.new("True", src3_md5, src3_md5, "False", "True")
      ])
    end

    let(:cmd_output) do
      o = WinRM::Output.new
      o[:exitcode] = 0
      o
    end

    let(:decode_output) do
      create_decode_output([
        DecodeEntry.new(dst1, "True", src1_md5, src1_md5, ps1_tmpfile, nil),
        DecodeEntry.new(dst2, "True", src2_md5, src2_md5, ps2_tmpfile, nil)
      ])
    end

    let(:upload) { transporter.upload([local1, local2, local3], remote) }

    before do
      service.stubs(:run_cmd).
        returns(cmd_output)

      service.stubs(:run_powershell_script).
        with { |script| script =~ /^Check-Files .+ \| ConvertTo-Csv/ }.
        returns(check_output)

      service.stubs(:run_powershell_script).
        with { |script| script =~ /^Decode-Files .+ \| ConvertTo-Csv/ }.
        returns(decode_output)
    end

    it "truncates a zero-byte hash_file for check_files" do
      service.expects(:run_cmd).with { |cmd, *_|
        cmd =~ regexify(%{echo|set /p=>"%TEMP%\\hash-alpha.txt"})
      }.returns(cmd_output)

      upload
    end

    it "uploads the hash_file in chunks for check_files" do
      hash = Kitchen::Util.outdent!(<<-HASH.chomp)
        @{
          "#{dst1}" = "#{src1_md5}"
          "#{dst2}" = "#{src2_md5}"
          "#{dst3}" = "#{src3_md5}"
        }
      HASH

      service.expects(:run_cmd).
        with(%{echo #{base64(hash)} >> "%TEMP%\\hash-alpha.txt"}).
        returns(cmd_output).times(1)

      upload
    end

    it "sets hash_file and runs the check_files powershell script" do
      service.expects(:run_powershell_script).with { |script|
        script =~ regexify(%{$hash_file = "$env:TEMP\\hash-alpha.txt"}) &&
          script =~ regexify(
            "Check-Files (Invoke-Input $hash_file) | " \
            "ConvertTo-Csv -NoTypeInformation")
      }.returns(check_output)

      upload
    end

    it "only uploads dirty files" do
      service.expects(:run_cmd).
        with(%{echo #{base64(IO.read(local1))} >> "#{cmd1_tmpfile}"})
      service.expects(:run_cmd).
        with(%{echo #{base64(IO.read(local2))} >> "#{cmd2_tmpfile}"})
      service.expects(:run_cmd).
        with(%{echo #{base64(IO.read(local3))} >> "#{cmd3_tmpfile}"}).
        never

      upload
    end

    it "truncates a zero-byte hash_file for decode_files" do
      service.expects(:run_cmd).with { |cmd, *_|
        cmd =~ regexify(%{echo|set /p=>"%TEMP%\\hash-beta.txt"})
      }.returns(cmd_output)

      upload
    end

    it "uploads the hash_file in chunks for decode_files" do
      hash = Kitchen::Util.outdent!(<<-HASH.chomp)
        @{
          "#{ps1_tmpfile}" = @{
            "dst" = "#{dst1}"
          }
          "#{ps2_tmpfile}" = @{
            "dst" = "#{dst2}"
          }
        }
      HASH

      service.expects(:run_cmd).
        with(%{echo #{base64(hash)} >> "%TEMP%\\hash-beta.txt"}).
        returns(cmd_output).times(1)

      upload
    end

    it "sets hash_file and runs the decode_files powershell script" do
      service.expects(:run_powershell_script).with { |script|
        script =~ regexify(%{$hash_file = "$env:TEMP\\hash-beta.txt"}) &&
          script =~ regexify(
            "Decode-Files (Invoke-Input $hash_file) | " \
            "ConvertTo-Csv -NoTypeInformation")
      }.returns(check_output)

      upload
    end

    it "returns a report hash" do
      report = upload

      report.fetch(src1_md5).must_equal(
        "src"         => local1,
        "dst"         => dst1,
        "tmpfile"     => ps1_tmpfile,
        "tmpzip"      => nil,
        "src_md5"     => src1_md5,
        "dst_md5"     => src1_md5,
        "chk_exists"  => "False",
        "chk_dirty"   => "True",
        "verifies"    => "True",
        "size"        => size1,
        "xfered"      => size1 / 3 * 4,
        "chunks"      => (size1 / 6000.to_f).ceil
      )
      report.fetch(src2_md5).must_equal(
        "src"         => local2,
        "dst"         => dst2,
        "tmpfile"     => ps2_tmpfile,
        "tmpzip"      => nil,
        "src_md5"     => src2_md5,
        "dst_md5"     => src2_md5,
        "chk_exists"  => "True",
        "chk_dirty"   => "True",
        "verifies"    => "True",
        "size"        => size2,
        "xfered"      => size2 / 3 * 4,
        "chunks"      => (size2 / 6000.to_f).ceil
      )
      report.fetch(src3_md5).must_equal(
        "src"         => local3,
        "dst"         => dst3,
        "src_md5"     => src3_md5,
        "dst_md5"     => src3_md5,
        "chk_exists"  => "True",
        "chk_dirty"   => "False",
        "verifies"    => "True",
        "size"        => size3
      )
    end

    describe "when a failed check command is returned" do

      def check_output
        o = WinRM::Output.new
        o[:exitcode] = 10
        o[:data].concat([{ :stderr => "Oh noes\n" }])
        o
      end

      it "raises a FileTransporterFailed error" do
        err = proc {
          upload
        }.must_raise Kitchen::Transport::Winrm::FileTransporterFailed
        err.message.must_match regexify(
          "Upload failed (exitcode: 10)", :partial_line)
      end
    end

    describe "when a failed decode command is returned" do

      def decode_output
        o = WinRM::Output.new
        o[:exitcode] = 10
        o[:data].concat([{ :stderr => "Oh noes\n" }])
        o
      end

      it "raises a FileTransporterFailed error" do
        err = proc {
          upload
        }.must_raise Kitchen::Transport::Winrm::FileTransporterFailed
        err.message.must_match regexify(
          "Upload failed (exitcode: 10)", :partial_line)
      end
    end
  end

  it "raises an exception when local file or directory is not found" do
    proc { transporter.upload("/a/b/c/nope", "C:\\nopeland") }.
      must_raise Errno::ENOENT
  end

  def base64(string)
    Base64.strict_encode64(string)
  end

  def create_check_output(entries)
    csv = CSV.generate(:force_quotes => true) do |rows|
      rows << CheckEntry.new.members.map(&:to_s)
      entries.each { |entry| rows << entry.to_a }
    end

    o = WinRM::Output.new
    o[:exitcode] = 0
    o[:data].concat(csv.lines.map { |line| { :stdout => line } })
    o
  end

  def create_decode_output(entries)
    csv = CSV.generate(:force_quotes => true) do |rows|
      rows << DecodeEntry.new.members.map(&:to_s)
      entries.each { |entry| rows << entry.to_a }
    end

    o = WinRM::Output.new
    o[:exitcode] = 0
    o[:data].concat(csv.lines.map { |line| { :stdout => line } })
    o
  end

  def create_tempfile(name, content)
    pre, _, ext = name.rpartition(".")
    file = Tempfile.open(["#{pre}-", ".#{ext}"])
    @tempfiles << file
    file.write(content)
    file.close
    file.path
  end

  def md5sum(local)
    Digest::MD5.file(local).hexdigest
  end

  def regexify(str, line = :whole_line)
    r = Regexp.escape(str)
    r = "^#{r}$" if line == :whole_line
    Regexp.new(r)
  end
end

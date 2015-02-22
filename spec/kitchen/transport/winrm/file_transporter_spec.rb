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

  CheckEntry = Struct.new(:dst, :chk_exists, :src_md5, :dst_md5, :chk_dirty, :verifies)
  DecodeEntry = Struct.new(:dst, :verifies, :src_md5, :dst_md5, :tmpfile)

  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }

  let(:service) do
    s = mock("winrm_service")
    s.responds_like_instance_of(WinRM::WinRMWebService)
    s
  end

  let(:transporter) do
    Kitchen::Transport::Winrm::FileTransporter.new(service, logger)
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
      it "runs the check_files powershell script" do
        service.expects(:run_powershell_script).with { |script|
          script =~ regexify("Function Get-MD5Sum($src) {") &&
            script =~ regexify("Function Check-Files($hash) {") &&
            script =~ regexify(
              "Check-Files $files | ConvertTo-Csv -NoTypeInformation")
        }.returns(check_output)

        upload
      end

      it "sets a powershell files hash in the check_files script" do
        service.expects(:run_powershell_script).with { |script|
          script =~ regexify(%[$files = @{ "#{dst}" = "#{src_md5}" }]) &&
            script =~ regexify(
              "Check-Files $files | ConvertTo-Csv -NoTypeInformation")
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

      it "runs the decode_files powershell script" do
        service.expects(:run_powershell_script).with { |script|
          script =~ regexify("Function Get-MD5Sum($src) {") &&
            script =~ regexify("Function Decode-Files($hash) {") &&
            script =~ regexify(
              "Decode-Files $files | ConvertTo-Csv -NoTypeInformation")
        }.returns(check_output)

        upload
      end

      it "sets a powershell files hash in the decode_files script" do
        service.expects(:run_powershell_script).with { |script|
          script =~ regexify(%[$files = @{ "#{ps_tmpfile}" = "#{dst}" }]) &&
            script =~ regexify(
              "Decode-Files $files | ConvertTo-Csv -NoTypeInformation")
        }.returns(check_output)

        upload
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    describe "for a new file" do

      let(:check_output) do
        create_check_output([
          CheckEntry.new(dst, "False", src_md5, nil, "True", "False")
        ])
      end

      let(:cmd_output) do
        o = WinRM::Output.new
        o[:exitcode] = 0
        o
      end

      let(:decode_output) do
        create_decode_output([
          DecodeEntry.new(dst, "True", src_md5, src_md5, ps_tmpfile)
        ])
      end

      before do
        service.stubs(:run_powershell_script).
          with { |script| script =~ /^Check-Files \$files / }.
          returns(check_output)

        service.stubs(:run_cmd).
          returns(cmd_output)

        service.stubs(:run_powershell_script).
          with { |script| script =~ /^Decode-Files \$files / }.
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
    end

    describe "for an out of date (dirty) file" do

      let(:check_output) do
        create_check_output([
          CheckEntry.new(dst, "True", src_md5, "aabbcc", "True", "False")
        ])
      end

      let(:cmd_output) do
        o = WinRM::Output.new
        o[:exitcode] = 0
        o
      end

      let(:decode_output) do
        create_decode_output([
          DecodeEntry.new(dst, "True", src_md5, src_md5, ps_tmpfile)
        ])
      end

      before do
        service.stubs(:run_powershell_script).
          with { |script| script =~ /^Check-Files \$files / }.
          returns(check_output)

        service.stubs(:run_cmd).
          returns(cmd_output)

        service.stubs(:run_powershell_script).
          with { |script| script =~ /^Decode-Files \$files / }.
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
          CheckEntry.new(dst, "True", src_md5, src_md5, "False", "True")
        ])
      end

      before do
        service.stubs(:run_powershell_script).
          with { |script| script =~ /^Check-Files \$files / }.
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
        CheckEntry.new(dst1, "False", src1_md5, nil, "True", "False"),      # new
        CheckEntry.new(dst2, "True", src2_md5, "aabbcc", "True", "False"),  # out-of-date
        CheckEntry.new(dst3, "True", src3_md5, src3_md5, "False", "True")   # current
      ])
    end

    let(:cmd_output) do
      o = WinRM::Output.new
      o[:exitcode] = 0
      o
    end

    let(:decode_output) do
      create_decode_output([
        DecodeEntry.new(dst1, "True", src1_md5, src1_md5, ps1_tmpfile),
        DecodeEntry.new(dst2, "True", src2_md5, src2_md5, ps2_tmpfile)
      ])
    end

    let(:upload) { transporter.upload([local1, local2, local3], remote) }

    before do
      service.stubs(:run_powershell_script).
        with { |script| script =~ /^Check-Files \$files / }.
        returns(check_output)

      service.stubs(:run_cmd).
        returns(cmd_output)

      service.stubs(:run_powershell_script).
        with { |script| script =~ /^Decode-Files \$files / }.
        returns(decode_output)
    end

    it "sets a powershell files hash in the check_files script" do
      files = [
        %{"#{dst1}" = "#{src1_md5}"},
        %{"#{dst2}" = "#{src2_md5}"},
        %{"#{dst3}" = "#{src3_md5}"}
      ]

      service.expects(:run_powershell_script).with { |script|
        script =~ regexify(%[$files = @{ #{files.join("; ")} }]) &&
          script =~ regexify(
            "Check-Files $files | ConvertTo-Csv -NoTypeInformation")
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

    it "sets a powershell files hash in the check_files script" do
      files = [
        %{"#{ps1_tmpfile}" = "#{dst1}"},
        %{"#{ps2_tmpfile}" = "#{dst2}"}
      ]

      service.expects(:run_powershell_script).with { |script|
        script =~ regexify(%[$files = @{ #{files.join("; ")} }]) &&
          script =~ regexify(
            "Decode-Files $files | ConvertTo-Csv -NoTypeInformation")
      }.returns(check_output)

      upload
    end

    it "returns a report hash" do
      report = upload

      report.fetch(src1_md5).must_equal(
        "src"         => local1,
        "dst"         => dst1,
        "tmpfile"     => ps1_tmpfile,
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

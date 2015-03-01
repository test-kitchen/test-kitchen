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

require "kitchen"
require "kitchen/transport/winrm/tmp_zip"

require "logger"

describe Kitchen::Transport::Winrm::TmpZip do

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }

  let(:src_dir) do
    tmpdir = Pathname.new(Dir.mktmpdir)
    @tmpdirs << tmpdir
    src_dir = tmpdir.join("src")
    sub_dir = src_dir.join("veggies")

    src_dir.mkpath
    create_local_file(src_dir.join("apple.txt"), "appleapple")
    create_local_file(src_dir.join("banana.txt"), "bananabanana")
    create_local_file(src_dir.join("cherry.txt"), "cherrycherry")
    sub_dir.mkpath
    create_local_file(sub_dir.join("carrot.txt"), "carrotcarrot")
    src_dir
  end

  let(:tmp_zip) { Kitchen::Transport::Winrm::TmpZip.new(src_dir, logger) }

  before  { @tmpdirs = [] }

  after do
    @tmpdirs.each(&:rmtree)
    tmp_zip.unlink if tmp_zip.path
  end

  it "#path returns path to created zip file" do
    tmp_zip.path.file?.must_equal true
  end

  it "#unlink removes the file" do
    path = tmp_zip.path
    path.file?.must_equal true

    tmp_zip.unlink

    path.file?.must_equal false
    tmp_zip.path.must_equal nil
  end

  describe "for a zip file containing the base directory" do

    let(:tmp_zip) { Kitchen::Transport::Winrm::TmpZip.new(src_dir, logger) }

    it "contains the input entries" do
      zip = Zip::File.new(tmp_zip.path)

      zip.map(&:name).sort.must_equal(
        %W[src/apple.txt src/banana.txt src/cherry.txt src/veggies/carrot.txt]
      )
      zip.read("src/apple.txt").must_equal "appleapple"
      zip.read("src/banana.txt").must_equal "bananabanana"
      zip.read("src/cherry.txt").must_equal "cherrycherry"
      zip.read("src/veggies/carrot.txt").must_equal "carrotcarrot"
    end

    it "logs to debug" do
      tmp_zip
      subject = "[TmpZip::#{tmp_zip.path}]"
      logged = logged_output.string

      logged.must_match debug_line("#{subject} +++ Adding src/apple.txt")
      logged.must_match debug_line("#{subject} +++ Adding src/banana.txt")
      logged.must_match debug_line("#{subject} +++ Adding src/cherry.txt")
      logged.must_match debug_line("#{subject} +++ Adding src/veggies/carrot.txt")
    end
  end

  describe "for a zip file containing entries under the base directory" do

    let(:tmp_zip) { Kitchen::Transport::Winrm::TmpZip.new("#{src_dir}/", logger) }

    it "contains the input entries" do
      zip = Zip::File.new(tmp_zip.path)

      zip.map(&:name).sort.must_equal(
        %W[apple.txt banana.txt cherry.txt veggies/carrot.txt]
      )
      zip.read("apple.txt").must_equal "appleapple"
      zip.read("banana.txt").must_equal "bananabanana"
      zip.read("cherry.txt").must_equal "cherrycherry"
      zip.read("veggies/carrot.txt").must_equal "carrotcarrot"
    end

    it "logs to debug" do
      tmp_zip
      subject = "[TmpZip::#{tmp_zip.path}]"
      logged = logged_output.string

      logged.must_match debug_line("#{subject} +++ Adding apple.txt")
      logged.must_match debug_line("#{subject} +++ Adding banana.txt")
      logged.must_match debug_line("#{subject} +++ Adding cherry.txt")
      logged.must_match debug_line("#{subject} +++ Adding veggies/carrot.txt")
    end
  end

  def create_local_file(path, content)
    path.open("wb") { |file| file.write(content) }
  end

  def debug_line(msg)
    %r{^D, .* : #{Regexp.escape(msg)}$}
  end
end

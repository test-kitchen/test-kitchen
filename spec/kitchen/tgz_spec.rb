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

require_relative "../spec_helper"

require "tempfile"
require "fileutils"
require "kitchen/tgz"

describe Kitchen::Tgz do
  #
  # Create a temporary file, of a specified length. The content of the file
  # will be an increasing sequence of byte values. This ensure that files
  # will always be created in the exactly the same way in each test run, and
  # we"ll therefore create predictable Tgz files.
  #
  def create_file(path, size)
    dir_name = File.dirname(path)
    FileUtils.mkdir_p(dir_name)
    File.open(path, "wb") do |file|
      (0...size).each do |i|
        file.print((i % 256).chr)
      end
    end
  end

  #
  # Create a temporary directory, populated with files. This directory will
  # be tar-gzipped in our test cases.
  #
  def create_temp_files(files_hash)
    dir = Dir.mktmpdir("test")
    files_hash.each_pair { |name, size| create_file("#{dir}/#{name}", size) }
    dir
  end

  #
  # Remove the temporary directory created by
  #
  def remove_temp_files(directory)
    FileUtils.rm_r(directory)
  end

  #
  # Test cases
  #
  it "can be created with a user-specified output file name" do
    # create a temporary file, to use as the output file we'll provide to TGZ
    user_chosen_output_file = Tempfile.new("test")
    user_chosen_output_file_name = user_chosen_output_file.path

    # create a new Tgz object, with our user-specified output file name.
    test_tgz = Kitchen::Tgz.new(user_chosen_output_file_name)

    # validate that Tgz is using the correct output path.
    @tgz_output_path = test_tgz.path
    test_tgz.path.must_equal user_chosen_output_file_name

    # write the output to disk (with no members in the tgz file)
    test_tgz.close
    File.exist?(test_tgz.path).must_equal true
    user_chosen_output_file.close
  end

  it "can be created with an auto-generated output file name" do
    # create a new Tgz object, with an auto-generated output file name.
    test_tgz = Kitchen::Tgz.new
    @tgz_output_path = test_tgz.path

    # write the output to disk (with no members in the tgz file)
    test_tgz.close
    File.exist?(test_tgz.path).must_equal true
  end

  it "rejects output file names that are not writable" do
    proc do
      Kitchen::Tgz.new("/invalid/missing/path")
    end.must_raise Errno::ENOENT
  end

  it "allows files to be archived within a single directory" do
    test_tgz = Kitchen::Tgz.new
    @tgz_output_path = test_tgz.path

    # create a number of test files (of varying lengths) into a temporary
    # directory, add them to the archive, then flush the file to disk.
    @temp_directory = create_temp_files(
      "file_A" => 100,
      "file_B" => 200,
      "file_C" => 300
    )
    test_tgz.add_files(@temp_directory, %w[file_A file_B file_C])
    test_tgz.close

    Kitchen::Tgz.original_size(@tgz_output_path).must_equal 4096
  end

  it "allows files to be archived in a directory hierarchy" do
    test_tgz = Kitchen::Tgz.new
    @tgz_output_path = test_tgz.path

    # create test files within subdirectories
    @temp_directory = create_temp_files(
      "dirA/dirB/file_A" => 1000,
      "dirA/dirB/file_B" => 2000,
      "dirA/file_C" => 3000
    )
    test_tgz.add_files(@temp_directory, ["dirA"])
    test_tgz.close

    Kitchen::Tgz.original_size(@tgz_output_path).must_equal 8704
  end

  it "allows large files to added" do
    test_tgz = Kitchen::Tgz.new
    @tgz_output_path = test_tgz.path

    @temp_directory = create_temp_files(
      "dirA/dirB/file_A" => 1_000_000
    )
    test_tgz.add_files(@temp_directory, ["dirA"])
    test_tgz.close

    Kitchen::Tgz.original_size(@tgz_output_path).must_equal 1001984
  end

  it "reject member file names that do not exist" do
    test_tgz = Kitchen::Tgz.new
    @tgz_output_path = test_tgz.path
    proc do
      test_tgz.add_files("/", ["non-existed-file"])
    end.must_raise Errno::ENOENT
    test_tgz.close
  end

  # clean up
  after(:each) do
    File.unlink(@tgz_output_path) if @tgz_output_path &&
        File.exist?(@tgz_output_path)
    remove_temp_files(@temp_directory) if @temp_directory
  end
end

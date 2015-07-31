# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, Fletcher Nichol
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

gem "minitest"

if ENV["CODECLIMATE_REPO_TOKEN"]
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
elsif ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.profiles.define "gem" do
    command_name "Specs"

    add_filter ".gem/"
    add_filter "/spec/"
    add_filter "/lib/vendor/"

    add_group "Libraries", "/lib/"
  end
  SimpleCov.start "gem"
end

require "fakefs/safe"
require "minitest/autorun"
require "mocha/setup"
require "tempfile"

# Nasty hack to redefine IO.read in terms of File#read for fakefs
class IO
  def self.read(*args)
    length = args[1]
    offset = args[2]
    opt = args[3]
    if length.is_a? Hash
      opt = length
      length = nil
    elsif offset.is_a? Hash
      opt = offset
    end
    if opt && opt.key?(:mode)
      File.open(args[0], opt) { |f| f.read(length) }
    else
      File.open(args[0], "rb", opt) { |f| f.read(length) }
    end
  end
end

def with_fake_fs
  FakeFS.activate!
  FileUtils.mkdir_p("/tmp")
  yield
  FakeFS.deactivate!
  FakeFS::FileSystem.clear
end

def running_tests_on_windows?
  ENV["OS"] == "Windows_NT"
end

def os_safe_root_path(root_path)
  if running_tests_on_windows?
    "#{File.join(ENV["SystemDrive"], root_path)}"
  else
    root_path
  end
end

def padded_octal_string(integer)
  integer.to_s(8).rjust(4, "0")
end

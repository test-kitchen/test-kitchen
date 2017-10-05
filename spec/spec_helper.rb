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

begin
  require "simplecov"
  SimpleCov.profiles.define "gem" do
    command_name "Specs"

    add_filter ".gem/"
    add_filter "/spec/"
    add_filter "/lib/vendor/"

    add_group "Libraries", "/lib/"
  end
  SimpleCov.start "gem"
rescue LoadError
  puts "add simplecov to Gemfile.local or GEMFILE_MOD to generate code coverage"
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

# Hack to sort results in `Dir.entries` only within the yielded block, to limit
# the "behavior pollution" to other code. This was needed for Net::SCP, as
# recursive directory upload doesn't sort the file and directory upload
# candidates which leads to different results based on the underlying
# filesystem (i.e. lexically sorted, inode insertion, mtime/atime, total
# randomness, etc.)
#
# See: https://github.com/net-ssh/net-scp/blob/a24948/lib/net/scp/upload.rb#L52

$_sort_dir_entries = false
Dir.singleton_class.prepend(Module.new do
  def entries(*args)
    super.tap do |rv|
      rv.sort! if $_sort_dir_entries
    end
  end
end)

def with_sorted_dir_entries(&block)
  old_sort_dir_entries = $_sort_dir_entries
  $_sort_dir_entries = true
  yield
ensure
  $_sort_dir_entries = old_sort_dir_entries
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
    File.join(ENV["SystemDrive"], root_path).to_s
  else
    root_path
  end
end

def padded_octal_string(integer)
  integer.to_s(8).rjust(4, "0")
end

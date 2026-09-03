#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Must be configured before anything under lib/ is loaded, so it is opt-in via
# COVERAGE=1 to keep the default local run fast.
if ENV["COVERAGE"]
  require "simplecov"

  SimpleCov.command_name "unit"

  SimpleCov.start do
    add_filter %r{^/spec/}
    add_filter %r{^/features/}
    add_filter %r{^/lib/vendor/} # vendored third-party code

    enable_coverage :branch

    # A ratchet, not a target. Raise these as coverage improves; never lower
    # them to make a build pass.
    minimum_coverage line: 92, branch: 77
  end
end

gem "minitest"

require "fakefs/safe"
require "minitest/autorun"
require "mocha/minitest"
require "tempfile"

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
ensure
  FakeFS.deactivate!
  FakeFS::FileSystem.clear
end

# Runs a block with ENV temporarily replaced, then restores the original
# environment. Specs that assign to ENV directly leak into every example that
# runs after them, which makes failures depend on test order.
#
#   with_env("HTTP_PROXY" => "http://proxy") { ... }
#
# A nil value unsets the variable for the duration of the block.
def with_env(vars)
  original = ENV.to_hash
  vars.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  yield
ensure
  ENV.replace(original)
end

def running_tests_on_windows?
  ENV["OS"] == "Windows_NT"
end

def os_safe_root_path(root_path)
  if running_tests_on_windows?
    File.join(Dir.pwd[0..1], root_path).to_s
    # File.join(ENV["SystemDrive"], root_path).to_s
  else
    root_path
  end
end

def padded_octal_string(integer)
  integer.to_s(8).rjust(4, "0")
end

def os_safe_temp_path(temp_path)
  if running_tests_on_windows? && ENV["USERNAME"].length > 8
    short_name = ENV["USERNAME"].upcase[0..5] + "~1"
    updated_path = temp_path.sub(ENV["USERNAME"], short_name)
    return updated_path unless updated_path.nil?
  end
  temp_path
end

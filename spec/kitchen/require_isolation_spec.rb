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

require_relative "../spec_helper"

require "open3"

# Every file under lib/ must be loadable on its own.
#
# Driver, provisioner, verifier and transport plugins routinely require a
# single Test Kitchen file (`require "kitchen/shell_out"`) rather than all of
# `kitchen`. When a file leans on a constant that some *other* file happened to
# require first, it loads fine inside this suite -- which loads everything --
# and blows up with a NameError for the plugin author.
#
# The suite cannot catch that from inside a single process, so each file is
# required in a clean subprocess. Subprocesses are I/O bound, so they run on a
# small thread pool to keep this to roughly a second.
describe "every file in lib" do
  def self.lib_dir
    @lib_dir ||= File.expand_path("../../lib", __dir__)
  end

  def self.lib_requires
    Dir.glob("**/*.rb", base: lib_dir).sort.map { |path| path.sub(/\.rb\z/, "") }
  end

  def self.require_in_clean_process(feature)
    out, status = Open3.capture2e(
      Gem.ruby, "-I", lib_dir, "-e", "require #{feature.dump}"
    )
    [feature, status.success?, out]
  end

  # Fan out across the whole graph once, then assert per file, so a broken
  # require names itself instead of hiding behind the first failure.
  results = lib_requires.each_slice(24).flat_map do |batch|
    batch.map { |feature| Thread.new { require_in_clean_process(feature) } }.map(&:value)
  end

  results.each do |feature, ok, out|
    it "can require #{feature.inspect} on its own" do
      _(ok).must_equal true, "`require #{feature.dump}` failed:\n\n#{out}"
    end
  end
end

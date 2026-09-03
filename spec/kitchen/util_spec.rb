#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

require "logger"
require "open3"

require "kitchen/util"

describe Kitchen::Util do
  describe ".to_logger_level" do
    it "returns nil for invalid symbols" do
      _(Kitchen::Util.to_logger_level(:nope)).must_be_nil
    end

    %w{debug info warn error fatal}.each do |level|
      it "returns Logger::#{level.upcase} for :#{level} input" do
        _(Kitchen::Util.to_logger_level(level.to_sym))
          .must_equal Logger.const_get(level.upcase)
      end
    end
  end

  describe ".from_logger_level" do
    it "returns :fatal for invalid symbols" do
      _(Kitchen::Util.from_logger_level("nope"))
        .must_equal :fatal
    end

    %w{debug info warn error fatal}.each do |level|
      it "returns :#{level} for Logger::#{level.upcase} input" do
        _(Kitchen::Util.from_logger_level(Logger.const_get(level.upcase)))
          .must_equal(level.to_sym)
      end
    end
  end

  describe ".symbolized_hash" do
    it "returns itself if not a hash" do
      obj = Object.new
      _(Kitchen::Util.symbolized_hash(obj)).must_equal obj
    end

    it "preserves a symbolized hash" do
      hash = { one: [{ two: "three" }] }
      _(Kitchen::Util.symbolized_hash(hash)).must_equal hash
    end

    it "converts string keys into symbols" do
      _(Kitchen::Util
        .symbolized_hash("one" => [{ "two" => :three, :four => "five" }]))
        .must_equal(one: [{ two: :three, four: "five" }])
    end
  end

  describe ".stringified_hash" do
    it "returns itself if not a hash" do
      obj = Object.new
      _(Kitchen::Util.stringified_hash(obj)).must_equal obj
    end

    it "preserves a stringified hash" do
      hash = { "one" => [{ "two" => "three" }] }
      _(Kitchen::Util.stringified_hash(hash)).must_equal hash
    end

    it "converts symbol keys into strings" do
      _(Kitchen::Util
        .stringified_hash(one: [{ :two => :three, "four" => "five" }]))
        .must_equal("one" => [{ "two" => :three, "four" => "five" }])
    end
  end

  describe ".mask_values" do
    it "masks a symbol-keyed value in a modern Hash#inspect string" do
      hash = { password: "s3cr3t", user: "root" }

      _(Kitchen::Util.mask_values("[SSH] <#{hash.inspect}>", %w{password}))
        .wont_include "s3cr3t"
    end

    it "masks a string-keyed value in a modern Hash#inspect string" do
      hash = { "password" => "s3cr3t" }

      _(Kitchen::Util.mask_values("[SSH] <#{hash.inspect}>", %w{password}))
        .wont_include "s3cr3t"
    end

    it "masks a value in a legacy hash rocket string" do
      _(Kitchen::Util.mask_values(%{<{:password=>"s3cr3t"}>}, %w{password}))
        .wont_include "s3cr3t"
    end

    it "masks every requested key" do
      hash = { password: "s3cr3t", ssh_http_proxy_password: "pr0xy" }
      masked = Kitchen::Util.mask_values(
        "[SSH] <#{hash.inspect}>", %w{password ssh_http_proxy_password}
      )

      _(masked).wont_include "s3cr3t"
      _(masked).wont_include "pr0xy"
    end

    it "leaves keys that were not requested alone" do
      hash = { password: "s3cr3t", user: "root" }

      _(Kitchen::Util.mask_values("[SSH] <#{hash.inspect}>", %w{password}))
        .must_include "root"
    end

    it "does not mask a key that merely ends with a requested key" do
      hash = { not_a_password: "keepme" }

      _(Kitchen::Util.mask_values("<#{hash.inspect}>", %w{password}))
        .must_include "keepme"
    end

    it "does not modify the string it was given" do
      hash = { password: "s3cr3t" }
      original = "[SSH] <#{hash.inspect}>"

      Kitchen::Util.mask_values(original, %w{password})

      _(original).must_include "s3cr3t"
    end

    it "masks a frozen string" do
      _(Kitchen::Util.mask_values(%{<{password: "s3cr3t"}>}.freeze, %w{password}))
        .wont_include "s3cr3t"
    end
  end

  describe ".duration" do
    it "turns nil into a zero" do
      _(Kitchen::Util.duration(nil))
        .must_equal "(0m0.00s)"
    end

    it "formats seconds to 2 digits" do
      _(Kitchen::Util.duration(60))
        .must_equal "(1m0.00s)"
    end

    it "formats large values into minutes and seconds" do
      _(Kitchen::Util.duration(48_033))
        .must_equal "(800m33.00s)"
    end
  end

  describe ".wrap_command" do
    it "returns the wrapped command" do
      _(Kitchen::Util.wrap_command("yoyo"))
        .must_equal("sh -c '\nyoyo\n'")
    end

    it "returns a false if command is nil" do
      _(Kitchen::Util.wrap_command(nil))
        .must_equal("sh -c '\nfalse\n'")
    end

    it "returns a true if command string is empty" do
      _(Kitchen::Util.wrap_command(""))
        .must_equal("sh -c '\ntrue\n'")
    end

    it "handles a command string with a trailing newline" do
      _(Kitchen::Util.wrap_command("yep\n"))
        .must_equal("sh -c '\nyep\n'")
    end
  end

  describe ".outdent!" do
    it "modifies the argument string in place, destructively" do
      string = +"yep"

      _(Kitchen::Util.outdent!(string).object_id)
        .must_equal string.object_id
    end

    it "returns the same string if no leading whitespace exists" do
      string = +"one\ntwo\nthree"

      _(Kitchen::Util.outdent!(string))
        .must_equal "one\ntwo\nthree"
    end

    it "strips same amount of leading whitespace as found on first line" do
      string = +"  one\n    two\n      three\nfour"

      _(Kitchen::Util.outdent!(string))
        .must_equal "one\n  two\n    three\nfour"
    end
  end

  describe ".shell_helpers" do
    %w{
      exists do_wget do_curl do_fetch do_perl do_python do_download
    }.each do |func|
      it "contains a #{func} shell function" do
        _(Kitchen::Util.shell_helpers).must_match "#{func}() {"
      end
    end

    it "does not contain bare single quotes" do
      _(Kitchen::Util.shell_helpers).wont_match "'"
    end

    def regexify(str)
      Regexp.new("^ +" + Regexp.escape(str) + "$")
    end
  end

  describe ".list_directory" do
    before do
      @root = Dir.mktmpdir
      FileUtils.touch(File.join(@root, "foo"))
      Dir.mkdir(File.join(@root, "bar"))
      FileUtils.touch(File.join(@root, ".foo"))
      FileUtils.touch(File.join(@root, "bar", "baz"))
      FileUtils.touch(File.join(@root, "bar", ".baz"))
    end

    after do
      FileUtils.remove_entry(@root)
    end

    it "returns [] when the directory does not exist" do
      _(Kitchen::Util.list_directory(File.join(@root, "notexist")))
        .must_equal []
    end

    it "lists one level with no dot files by default" do
      listed = Kitchen::Util.list_directory(@root)
      expected = %w{
        foo
        bar
      }.map { |f| File.join(@root, f) }
      _((listed - expected)).must_equal []
      _((expected - listed)).must_equal []
    end

    it "matches dot files only when include_dot" do
      listed = Kitchen::Util.list_directory(@root, include_dot: true)
      expected = [
        "foo",
        ".foo",
        "bar",
      ].map { |f| File.join(@root, f) }
      _((listed - expected)).must_equal []
      _((expected - listed)).must_equal []
    end

    it "recursively lists only when recurse" do
      listed = Kitchen::Util.list_directory(@root, recurse: true)
      expected = [
        "foo",
        "bar",
        "bar/baz",
      ].map { |f| File.join(@root, f) }
      _((listed - expected)).must_equal []
      _((expected - listed)).must_equal []
    end

    it "recursively lists and provides dots when recurse and include_dot" do
      listed = Kitchen::Util.list_directory(@root, recurse: true, include_dot: true)
      expected = [
        "foo",
        ".foo",
        "bar",
        "bar/baz",
        "bar/.",
        "bar/.baz",
      ].map { |f| File.join(@root, f) }
      # with Ruby 3.1, Dir.glob() does not return files such as "bar/."
      expected -= [File.join(@root, "bar/.")] if RUBY_VERSION >= "3.1"
      _((listed - expected)).must_equal []
      _((expected - listed)).must_equal []
    end
  end

  describe ".safe_glob" do
    before do
      @root = Dir.mktmpdir
      FileUtils.touch(File.join(@root, "foo"))
      Dir.mkdir(File.join(@root, "bar"))
      FileUtils.touch(File.join(@root, "foo"))
      FileUtils.touch(File.join(@root, "foo.rb"))
      FileUtils.touch(File.join(@root, "bar", "baz.rb"))
    end

    after do
      FileUtils.remove_entry(@root)
    end

    it "globs without parameters" do
      expected = []
      Dir.glob(File.join(@root, "**/*")) { |f| expected << os_safe_temp_path(f) }
      _(Kitchen::Util.safe_glob(@root, "**/*"))
        .must_equal expected
    end

    it "globs with parameters" do
      expected = []
      Dir.glob(File.join(@root, "**/*"), File::FNM_DOTMATCH) { |f| expected << os_safe_temp_path(f) }

      _(Kitchen::Util.safe_glob(@root, "**/*", File::FNM_DOTMATCH))
        .must_equal expected
    end

    it "globs a folder that does not exist" do
      dne_dir = File.join(@root, "notexist")
      _(Kitchen::Util.safe_glob(dne_dir, "**/*"))
        .must_equal Dir.glob(File.join(dne_dir, "**/*"))
    end
  end

  # Kitchen::Util is required directly by driver, provisioner and verifier
  # plugins, so it has to stand on its own without lib/kitchen.rb being
  # loaded first. These run in a subprocess because the rest of the suite has
  # already loaded the whole library into this process.
  describe "when required on its own" do
    def run_in_clean_process(code)
      Open3.capture2e(
        Gem.ruby, "-I", File.expand_path("../../lib", __dir__), "-e", code
      ).first
    end

    it "can call .list_directory without kitchen.rb being loaded" do
      out = run_in_clean_process(
        'require "kitchen/util"; Kitchen::Util.list_directory("."); print "OK"'
      )

      _(out).must_equal "OK"
    end

    it "can call .safe_glob without kitchen.rb being loaded" do
      out = run_in_clean_process(
        'require "kitchen/util"; Kitchen::Util.safe_glob(".", "*"); print "OK"'
      )

      _(out).must_equal "OK"
    end
  end
end

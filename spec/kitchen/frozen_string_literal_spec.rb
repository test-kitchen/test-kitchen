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

require "kitchen/base64_stream"
require "kitchen/util"

# Ruby 4 moves string literals towards being frozen. Literals in files without
# a `frozen_string_literal` magic comment are currently "chilled": they warn on
# mutation rather than raising. Running with --enable-frozen-string-literal
# turns those warnings into the FrozenError they will eventually become, so
# these specs pin the code paths that used to mutate a literal.
describe "frozen string literal compatibility" do
  def self.run_with_frozen_literals(code)
    lib = File.expand_path("../../lib", __dir__)
    Open3.capture2e(
      Gem.ruby, "--enable-frozen-string-literal", "-I", lib, "-e", code
    )
  end

  describe Kitchen::Base64Stream do
    it "round-trips a stream when literals are frozen" do
      out, status = self.class.run_with_frozen_literals(<<~RUBY)
        require "kitchen/base64_stream"
        require "stringio"

        encoded = StringIO.new
        Kitchen::Base64Stream.strict_encode(StringIO.new("hello world"), encoded)

        decoded = StringIO.new
        Kitchen::Base64Stream.strict_decode(StringIO.new(encoded.string), decoded)

        print decoded.string
      RUBY

      _(out).must_equal "hello world"
      _(status.success?).must_equal true
    end
  end

  describe Kitchen::Util do
    it ".outdent does not mutate its argument" do
      original = "  a\n    b\n  c\n"
      copy = original.dup

      Kitchen::Util.outdent(original)

      _(original).must_equal copy
    end

    it ".outdent accepts a frozen string" do
      _(Kitchen::Util.outdent("  a\n    b\n  c\n".freeze))
        .must_equal "a\n  b\nc\n"
    end

    it ".outdent matches .outdent! output" do
      _(Kitchen::Util.outdent("  a\n    b\n  c\n"))
        .must_equal Kitchen::Util.outdent!(+"  a\n    b\n  c\n")
    end

    it ".outdent! still mutates in place, for callers that rely on it" do
      string = +"  a\n    b\n  c\n"

      Kitchen::Util.outdent!(string)

      _(string).must_equal "a\n  b\nc\n"
    end
  end
end

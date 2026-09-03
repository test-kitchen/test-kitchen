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

require "kitchen/lazy_hash"

describe Kitchen::LazyHash do
  let(:context) do
    stub(color: "blue", metal: "heavy")
  end

  let(:hash_obj) do
    {
      shed_color: lambda(&:color),
      barn: "locked",
      genre: proc { |c| "#{c.metal} metal" },
    }
  end

  describe "#[]" do
    it "returns regular values for keys" do
      _(Kitchen::LazyHash.new(hash_obj, context)[:barn]).must_equal "locked"
    end

    it "invokes call on values that are lambdas" do
      _(Kitchen::LazyHash.new(hash_obj, context)[:shed_color]).must_equal "blue"
    end

    it "invokes call on values that are Procs" do
      _(Kitchen::LazyHash.new(hash_obj, context)[:genre]).must_equal "heavy metal"
    end
  end

  describe "#fetch" do
    it "returns regular hash values for keys" do
      _(Kitchen::LazyHash.new(hash_obj, context).fetch(:barn))
        .must_equal "locked"
    end

    it "invokes call on values that are lambdas" do
      _(Kitchen::LazyHash.new(hash_obj, context).fetch(:shed_color))
        .must_equal "blue"
    end

    it "invokes call on values that are Procs" do
      _(Kitchen::LazyHash.new(hash_obj, context).fetch(:genre))
        .must_equal "heavy metal"
    end

    it "uses a default value for unset values" do
      _(Kitchen::LazyHash.new(hash_obj, context).fetch(:nope, "candy"))
        .must_equal "candy"
    end

    it "uses a block for unset values" do
      _(Kitchen::LazyHash.new(hash_obj, context).fetch(:nope) { |key| "#{key} is costly" })
        .must_equal "nope is costly"
    end
  end

  describe "#[]=" do
    it "stores a regular value" do
      subject = Kitchen::LazyHash.new(hash_obj, context)
      subject[:new_key] = "fresh"

      _(subject[:new_key]).must_equal "fresh"
    end

    it "stores the value unrendered so callables stay lazy" do
      subject = Kitchen::LazyHash.new(hash_obj, context)
      subject[:late] = ->(c) { c.color }

      _(subject[:late]).must_equal "blue"
    end

    it "writes through to the underlying hash" do
      subject = Kitchen::LazyHash.new(hash_obj, context)
      subject[:barn] = "open"

      _(hash_obj[:barn]).must_equal "open"
    end
  end

  describe "#key?" do
    it "is true for a key that is set" do
      _(Kitchen::LazyHash.new(hash_obj, context).key?(:barn)).must_equal true
    end

    it "is false for a key that is not set" do
      _(Kitchen::LazyHash.new(hash_obj, context).key?(:nope)).must_equal false
    end

    it "does not invoke a callable value" do
      called = false
      subject = Kitchen::LazyHash.new({ trap: ->(_c) { called = true } }, context)

      _(subject.key?(:trap)).must_equal true
      _(called).must_equal false
    end
  end

  describe "#keys" do
    it "returns the underlying keys without rendering values" do
      called = false
      subject = Kitchen::LazyHash.new(
        { barn: "locked", trap: ->(_c) { called = true } }, context
      )

      _(subject.keys).must_equal %i{barn trap}
      _(called).must_equal false
    end
  end

  describe "#to_hash" do
    it "invokes any callable values and returns a Hash object" do
      converted = Kitchen::LazyHash.new(hash_obj, context).to_hash

      _(converted).must_be_instance_of Hash
      _(converted.fetch(:shed_color)).must_equal "blue"
      _(converted.fetch(:barn)).must_equal "locked"
      _(converted.fetch(:genre)).must_equal "heavy metal"
    end
  end

  describe "select" do
    it "calls Procs when appropriate" do
      _(Kitchen::LazyHash.new(hash_obj, context).select { |_, _| true })
        .must_equal shed_color: "blue", barn: "locked", genre: "heavy metal"
    end
  end

  describe "enumerable" do
    it "is an Enumerable" do
      assert Kitchen::LazyHash.new(hash_obj, context).is_a? Enumerable
    end

    it "returns an Enumerator from each() if no block given" do
      e = Kitchen::LazyHash.new(hash_obj, context).each
      e.is_a? Enumerator
      _(e.next).must_equal [:shed_color, "blue"]
      _(e.next).must_equal [:barn, "locked"]
      _(e.next).must_equal [:genre, "heavy metal"]
    end

    it "yields each item to the block if a block is given to each()" do
      items = Kitchen::LazyHash.new(hash_obj, context).map { |i| i }
      _(items).must_equal [[:shed_color, "blue"], [:barn, "locked"], [:genre, "heavy metal"]]
    end
  end
end

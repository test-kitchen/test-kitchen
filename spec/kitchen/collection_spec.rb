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

require_relative "../spec_helper"
require "ostruct"

require "kitchen/collection"

describe Kitchen::Collection do

  let(:collection) do
    Kitchen::Collection.new([
      obj("one"), obj("two", "a"), obj("two", "b"), obj("three")
    ])
  end

  it "transparently wraps an Array" do
    collection.must_be_instance_of Array
  end

  describe "#get" do

    it "returns a single object by its name" do
      collection.get("three").must_equal obj("three")
    end

    it "returns the first occurance of an object by its name" do
      collection.get("two").must_equal obj("two", "a")
    end

    it "returns nil if an object cannot be found by its name" do
      collection.get("nope").must_be_nil
    end
  end

  describe "#get_all" do

    it "returns a Collection of objects whose name matches the regex" do
      result = collection.get_all(/(one|three)/)
      result.size.must_equal 2
      result[0].must_equal obj("one")
      result[1].must_equal obj("three")
      result.get_all(/one/).size.must_equal 1
    end

    it "returns an empty Collection if no matches are found" do
      result = collection.get_all(/noppa/)
      result.must_equal []
      result.get("nahuh").must_be_nil
    end
  end

  describe "#as_name" do

    it "returns an Array of names as strings" do
      collection.as_names.must_equal %w[one two two three]
    end
  end

  private

  def obj(name, extra = nil)
    OpenStruct.new(:name => name, :extra => extra)
  end
end

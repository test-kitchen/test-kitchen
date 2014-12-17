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

require "kitchen/errors"
require "kitchen/suite"

describe Kitchen::Suite do

  let(:opts) do
    {
      :name => "suitezy",
      :includes => %w[testbuntu testcent],
      :excludes => %w[prodbuntu]
    }
  end

  let(:suite) { Kitchen::Suite.new(opts) }

  it "returns the name" do
    suite.name.must_equal "suitezy"
  end

  it "raises an ArgumentError if name is missing" do
    opts.delete(:name)
    proc { Kitchen::Suite.new(opts) }.must_raise Kitchen::ClientError
  end

  it "returns the includes" do
    suite.includes.must_equal %w[testbuntu testcent]
  end

  it "returns an empty Array when includes not given" do
    opts.delete(:includes)
    suite.includes.must_equal []
  end

  it "returns the excludes" do
    suite.excludes.must_equal %w[prodbuntu]
  end

  it "returns an empty Array when excludes not given" do
    opts.delete(:excludes)
    suite.excludes.must_equal []
  end
end

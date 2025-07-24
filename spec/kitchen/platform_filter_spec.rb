#
# Author:: Baptiste Courtois (<b.courtois@criteo.com>)
#
# Copyright (C) 2021, Baptiste Courtois
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

require "kitchen/platform_filter"

describe Kitchen::PlatformFilter do
  describe ".convert" do
    it "returns an array if a scalar is passed" do
      Kitchen::PlatformFilter.convert(nil).must_equal []
      Kitchen::PlatformFilter.convert("string").must_equal [Kitchen::PlatformFilter.new("string")]
    end

    it "just wraps simple strings" do
      Kitchen::PlatformFilter.convert(%w{CentOS windows-2016}).must_equal [Kitchen::PlatformFilter.new("CentOS"),
                                                                           Kitchen::PlatformFilter.new("windows-2016")]
    end

    it "converts regexp-like strings into Regexp before wrapping" do
      Kitchen::PlatformFilter.convert(%w{/^win/ /win$/}).must_equal [Kitchen::PlatformFilter.new(/^win/),
                                                                     Kitchen::PlatformFilter.new(/win$/)]
    end

    it "supports IgnoreCase Regexp option" do
      Kitchen::PlatformFilter.convert("/win/i").must_equal [Kitchen::PlatformFilter.new(/win/i)]
    end

    it "supports Extended Regexp option" do
      Kitchen::PlatformFilter.convert("/win/x").must_equal [Kitchen::PlatformFilter.new(/win/x)]
    end

    it "supports combination of IgnoreCase & Extended Regexp options" do
      Kitchen::PlatformFilter.convert(%w{/win/ix /win/xi}).must_equal [Kitchen::PlatformFilter.new(/win/ix),
                                                                       Kitchen::PlatformFilter.new(/win/ix)]
    end
  end

  describe ".new" do
    it "raises an ArgumentError if value is neither a string nor Regexp" do
      proc { Kitchen::PlatformFilter.new(Object.new) }.must_raise ::ArgumentError
    end
  end

  describe "#value" do
    it "returns the original value" do
      Kitchen::PlatformFilter.new("string").value.must_equal "string"
      Kitchen::PlatformFilter.new(/regexp/).value.must_equal(/regexp/)
    end
  end
end

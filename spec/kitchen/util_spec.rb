# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

require_relative '../spec_helper'

require 'logger'

require 'kitchen/util'

describe Kitchen::Util do

  describe '.to_logger_level' do

    it "returns nil for invalid symbols" do
      Kitchen::Util.to_logger_level(:nope).must_be_nil
    end

    %w{debug info warn error fatal}.each do |level|
      it "returns Logger::#{level.upcase} for :#{level} input" do
        Kitchen::Util.to_logger_level(level.to_sym).
          must_equal Logger.const_get(level.upcase)
      end
    end
  end

  describe ".from_logger_level" do

    it "returns :fatal for invalid symbols" do
      Kitchen::Util.from_logger_level("nope").must_equal :fatal
    end

    %w{debug info warn error fatal}.each do |level|
      it "returns :#{level} for Logger::#{level.upcase} input" do
        Kitchen::Util.from_logger_level(Logger.const_get(level.upcase)).
          must_equal(level.to_sym)
      end
    end
  end

  describe ".symbolized_hash" do

    it "returns itself if not a hash" do
      obj = Object.new
      Kitchen::Util.symbolized_hash(obj).must_equal obj
    end

    it "preserves a symbolized hash" do
      hash = { :one => [{ :two => "three" }] }
      Kitchen::Util.symbolized_hash(hash).must_equal hash
    end

    it "converts string keys into symbols" do
      Kitchen::Util.
        symbolized_hash("one" => [{ "two" => :three, :four => "five" }]).
        must_equal(:one => [{ :two => :three, :four => "five" }])
    end
  end

  describe ".stringified_hash" do

    it "returns itself if not a hash" do
      obj = Object.new
      Kitchen::Util.stringified_hash(obj).must_equal obj
    end

    it "preserves a stringified hash" do
      hash = { "one" => [{ "two" => "three" }] }
      Kitchen::Util.stringified_hash(hash).must_equal hash
    end

    it "converts symbol keys into strings" do
      Kitchen::Util.
        stringified_hash(:one => [{ :two => :three, "four" => "five" }]).
        must_equal("one" => [{ "two" => :three, "four" => "five" }])
    end
  end

  describe ".duration" do

    it "turns nil into a zero" do
      Kitchen::Util.duration(nil).must_equal "(0m0.00s)"
    end

    it "formats seconds to 2 digits" do
      Kitchen::Util.duration(60).must_equal "(1m0.00s)"
    end

    it "formats large values into minutes and seconds" do
      Kitchen::Util.duration(48033).must_equal "(800m33.00s)"
    end
  end

  describe ".shell_helpers" do

    %w{
      exists do_wget do_curl do_fetch do_perl do_python do_download
    }.each do |func|
      it "contains a #{func} shell function" do
        Kitchen::Util.shell_helpers.must_match "#{func}() {"
      end
    end

    it "does not contain bare single quotes" do
      Kitchen::Util.shell_helpers.wont_match "'"
    end

    def regexify(str)
      Regexp.new("^\s+" + Regexp.escape(str) + "$")
    end
  end
end

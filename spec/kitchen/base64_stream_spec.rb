# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2014, Fletcher Nichol
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
require "base64"
require "stringio"
require "securerandom"

require "kitchen/base64_stream"

describe Kitchen::Base64Stream do

  SHORT_BODIES = %w[you test wakkawakkawakka]

  describe ".strict_encode" do

    SHORT_BODIES.each do |body|
      it "encodes short payload ('#{body}') from input IO to output IO" do
        output = StringIO.new("", "wb")
        StringIO.open(body) do |input|
          Kitchen::Base64Stream.strict_encode(input, output)
        end

        output.string.must_equal Base64.strict_encode64(body)
      end
    end

    it "encodes a large payload from input IO to output IO" do
      body = SecureRandom.random_bytes(1048576 * 8)
      output = StringIO.new("", "wb")
      StringIO.open(body) do |input|
        Kitchen::Base64Stream.strict_encode(input, output)
      end

      output.string.must_equal Base64.strict_encode64(body)
    end
  end

  describe ".strict_decode" do

    SHORT_BODIES.map { |b| Base64.strict_encode64(b) }.each do |body|
      it "decodes short payload ('#{body}') from input IO to output IO" do
        output = StringIO.new("", "wb")
        StringIO.open(body) do |input|
          Kitchen::Base64Stream.strict_decode(input, output)
        end

        output.string.must_equal Base64.strict_decode64(body)
      end
    end

    it "decodes a large payload from input IO to output IO" do
      body = Base64.strict_encode64(SecureRandom.hex(1048576 * 8))
      output = StringIO.new("", "wb")
      StringIO.open(body) do |input|
        Kitchen::Base64Stream.strict_decode(input, output)
      end

      output.string.must_equal Base64.strict_decode64(body)
    end
  end
end

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

module Kitchen
  # Base64 encoder/decoder that operates on IO objects so as to minimize
  # memory allocations on large payloads.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  module Base64Stream
    # Encodes an input stream into a Base64 output stream. The input and ouput
    # objects must be opened IO resources. In other words, opening and closing
    # the resources are not the responsibilty of this method.
    #
    # @param io_in [#read] input stream
    # @param io_out [#write] output stream
    def self.strict_encode(io_in, io_out)
      buffer = ""
      io_out.write([buffer].pack("m0")) while io_in.read(3 * 1000, buffer)
      buffer = nil # rubocop:disable Lint/UselessAssignment
    end

    # Decodes a Base64 input stream into an output stream. The input and ouput
    # objects must be opened IO resources. In other words, opening and closing
    # the resources are not the responsibilty of this method.
    #
    # @param io_in [#read] input stream
    # @param io_out [#write] output stream
    def self.strict_decode(io_in, io_out)
      buffer = ""
      io_out.write(buffer.unpack("m0").first) while io_in.read(3 * 1000, buffer)
      buffer = nil # rubocop:disable Lint/UselessAssignment
    end
  end
end

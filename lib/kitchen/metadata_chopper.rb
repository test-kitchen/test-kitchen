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

module Kitchen

  # A rather insane and questionable class to quickly consume a metadata.rb
  # file and return the cookbook name and version attributes.
  #
  # @see https://twitter.com/fnichol/status/281650077901144064
  # @see https://gist.github.com/4343327
  class MetadataChopper < Hash

    # Return an Array containing the cookbook name and version attributes,
    # or nil values if they could not be parsed.
    #
    # @param metadata_file [String] path to a metadata.rb file
    # @return [Array<String>] array containing the cookbook name and version
    #   attributes or nil values if they could not be determined
    def self.extract(metadata_file)
      mc = new(File.expand_path(metadata_file))
      [mc[:name], mc[:version]]
    end

    # Creates a new instances and loads in the contents of the metdata.rb
    # file. If you value your life, you may want to avoid reading the
    # implementation.
    #
    # @param metadata_file [String] path to a metadata.rb file
    def initialize(metadata_file)
      instance_eval(IO.read(metadata_file), metadata_file)
    end

    def method_missing(meth, *args, &_block)
      self[meth] = args.first
    end
  end
end

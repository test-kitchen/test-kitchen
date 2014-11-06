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

require "delegate"

module Kitchen

  # Delegate class which adds the ability to find single and multiple
  # objects by their #name in an Array. Hey, it's better than monkey-patching
  # Array, right?
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Collection < SimpleDelegator

    # Returns a single object by its name, or nil if none are found.
    #
    # @param name [String] name of object
    # @return [Object] first match by name, or nil if none are found
    def get(name)
      __getobj__.find { |i| i.name == name }
    end

    # Returns a Collection of all objects whose #name is matched by the
    # regular expression.
    #
    # @param regexp [Regexp] a regular expression pattern
    # @return [Kitchen::Config::Collection<Object>] a new collection of
    #   matched objects
    def get_all(regexp)
      Kitchen::Collection.new(__getobj__.select { |i| i.name =~ regexp })
    end

    # Returns an Array of names from the collection as strings.
    #
    # @return [Array<String>] array of name strings
    def as_names
      __getobj__.map(&:name)
    end
  end
end

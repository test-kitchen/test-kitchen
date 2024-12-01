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

module Kitchen
  # A wrapper on Regexp and strings to mix them in platform filters.
  #
  # This should handle backward compatibility in most cases were
  # platform are matched against a filters array using Array.include?
  #
  # This wrapper does not work if filters arrays are converted to Set.
  #
  # @author Baptiste Courtois <b.courtois@criteo.com>
  class PlatformFilter
    # Pattern used to determine whether a filter should be handled as a Regexp
    REGEXP_LIKE_PATTERN = %r{^/(?<pattern>.*)/(?<options>[ix]*)$}

    # Converts platform filters into an array of PlatformFilter handling both strings and Regexp.
    # A string "looks-like" a regexp if it starts by / and end by / + Regexp options i or x
    #
    # @return [Array] filters with regexp-like string converted to PlatformRegexpFilter
    def self.convert(filters)
      ::Kernel.Array(filters).map do |filter|
        if (match = filter.match(REGEXP_LIKE_PATTERN))
          options = match["options"].include?("i") ? ::Regexp::IGNORECASE : 0
          options |= ::Regexp::EXTENDED if match["options"].include?("x")
          filter = ::Regexp.new(match["pattern"], options)
        end
        new(filter)
      end
    end

    # @return [Regexp] value of this filter
    attr_reader :value

    # Constructs a new filter.
    #
    # @param [Regexp,String] value of the filter
    def initialize(value)
      unless value.is_a?(::Regexp) || value.is_a?(::String)
        raise ::ArgumentError, "PlatformFilter#new requires value to be a String or a Regexp"
      end

      @value = value
    end

    # Override of the equality operator to check whether the wrapped Regexp match the given object.
    #
    # @param [Object] other object to compare to
    # @return [Boolean] whether the objects are equal or the wrapped Regexp matches the given string or symbol
    def ==(other)
      if @value.is_a?(::Regexp) && (other.is_a?(::String) || other.is_a?(::Symbol))
        @value =~ other
      else
        other == @value
      end
    end

    alias eq? ==
  end
end

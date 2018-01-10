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

require "delegate"

module Kitchen
  # A modifed Hash object that may contain callables as a value which must be
  # executed in the context of another object. This allows for delayed
  # evaluation of a hash value while still looking and largely feeling like a
  # normal Ruby Hash.
  #
  # @example normal hash accessing with regular values
  #
  #   data = {
  #     :symbol => true,
  #     "string" => "stuff"
  #   }
  #   context = "any object"
  #   lazy = Kitchen::Hash.new(data, context)
  #
  #   lazy[:symbol] # => true
  #   lazy.fetch("string") # => "stuff"
  #
  # @example hash with callable blocks as values
  #
  #   data = {
  #     :lambda => ->(c) { c.length },
  #     :proc => Proc.new { |c| c.reverse },
  #     :simple => "value"
  #   }
  #   context = "any object"
  #   lazy = Kitchen::Hash.new(data, context)
  #
  #   lazy[:lambda] # => 10
  #   lazy.fetch(:proc) # => "tcejbo yna"
  #   lazy[:simple] # => "value"
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class LazyHash < SimpleDelegator
    include Enumerable

    # Creates a new LazyHash using a Hash-like object to populate itself and
    # an object that can be used as context in value-callable blocks. The
    # context object can be used to compute values for keys at the time of
    # fetching the value.
    #
    # @param obj [Hash, Object] a hash-like object
    # @param context [Object] an object that can be used to compute values
    def initialize(obj, context)
      @context = context
      super(obj)
    end

    # Retrieves the rendered value object corresponding to the key object. If
    # not found, returns the default value.
    #
    # @param key [Object] hash key
    # @return [Object, nil] the value for key or the default value if key is
    #   not found
    def [](key)
      proc_or_val(__getobj__[key])
    end

    # Returns a rendered value from the hash for the given key. If the key
    # can't be found, there are several options: With no other arguments, it
    # will raise an KeyError exception; if default is given, then that will be
    # returned; if the optional code block is specified, then that will be run
    # and its result returned.
    #
    # @param key [Object] hash key
    # @param default [Object] default value if key is not set (optional)
    # @return [Object, nil] the value for the key or the default value if key
    #   is not found
    # @raise [KeyError] if the key is not found
    def fetch(key, default = :__undefined__, &block)
      case default
      when :__undefined__
        proc_or_val(__getobj__.fetch(key, &block))
      else
        proc_or_val(__getobj__.fetch(key, default, &block))
      end
    end

    # Returns a new Hash with all keys and rendered values of the LazyHash.
    #
    # @return [Hash] a new hash
    def to_hash
      hash = {}
      __getobj__.keys.each { |key| hash[key] = self[key] }
      hash
    end

    # Yields each key/value pair to the provided block.  Returns a new
    # Hash with only the keys and rendered values for which the block
    # returns true.
    #
    # @return [Hash] a new hash
    def select(&block)
      to_hash.select(&block)
    end

    # If no block provided, returns an enumerator over the keys and
    # rendered values in the underlying object.  If a block is
    # provided, calls the block once for each [key, rendered_value]
    # pair in the underlying object.
    #
    # @return [Enumerator, Array]
    def each(&block)
      to_hash.each(&block)
    end

    # Returns a new Hash after deleting the key-value pairs for which the block
    # returns true.
    #
    # @return [Hash] a new hash
    def delete_if(&block)
      to_hash.delete_if(&block)
    end

    private

    # Returns an object or invokes call with context if object is callable.
    #
    # @return [Object] an object
    # @api private
    def proc_or_val(thing)
      if thing.respond_to?(:call)
        thing.call(@context)
      else
        thing
      end
    end
  end
end

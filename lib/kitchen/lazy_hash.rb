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

require 'delegate'

module Kitchen

  # A modifed Hash object that may contain procs as a value which must be
  # executed in the context of another object.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class LazyHash < SimpleDelegator

    def initialize(obj, context)
      @context = context
      super(obj)
    end

    def [](key)
      proc_or_val = __getobj__[key]

      if proc_or_val.respond_to?(:call)
        proc_or_val.call(@context)
      else
        proc_or_val
      end
    end

    def to_hash
      hash = Hash.new
      __getobj__.keys.each { |key| hash[key] = self[key] }
      hash
    end
  end
end

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

  # Stateless utility methods used in different contexts. Essentially a mini
  # PassiveSupport library.
  module Util

    def self.to_logger_level(symbol)
      return nil unless [:debug, :info, :warn, :error, :fatal].include?(symbol)

      Logger.const_get(symbol.to_s.upcase)
    end

    def self.from_logger_level(const)
      case const
      when Logger::DEBUG then :debug
      when Logger::INFO then :info
      when Logger::WARN then :warn
      when Logger::ERROR then :error
      else :fatal
      end
    end

    def self.symbolized_hash(obj)
      if obj.is_a?(Hash)
        obj.inject({}) { |h, (k, v)| h[k.to_sym] = symbolized_hash(v) ; h }
      elsif obj.is_a?(Array)
        obj.inject([]) { |a, v| a << symbolized_hash(v) ; a }
      else
        obj
      end
    end

    def self.stringified_hash(obj)
      if obj.is_a?(Hash)
        obj.inject({}) { |h, (k, v)| h[k.to_s] = symbolized_hash(v) ; h }
      elsif obj.is_a?(Array)
        obj.inject([]) { |a, v| a << symbolized_hash(v) ; a }
      else
        obj
      end
    end

    def self.duration(total)
      minutes = (total / 60).to_i
      seconds = (total - (minutes * 60))
      "(%dm%.2fs)" % [minutes, seconds]
    end
  end
end

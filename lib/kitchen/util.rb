# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, 2013, 2014, Fletcher Nichol
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
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  module Util

    # Returns the standard library Logger level constants for a given symbol
    # representation.
    #
    # @param symbol [Symbol] symbol representation of a logger level (:debug,
    #   :info, :warn, :error, :fatal)
    # @return [Integer] Logger::Severity constant value or nil if input is not
    #   valid
    def self.to_logger_level(symbol)
      return nil unless [:debug, :info, :warn, :error, :fatal].include?(symbol)

      Logger.const_get(symbol.to_s.upcase)
    end

    # Returns the symbol represenation of a logging levels for a given
    # standard library Logger::Severity constant.
    #
    # @param const [Integer] Logger::Severity constant value for a logging
    #   level (Logger::DEBUG, Logger::INFO, Logger::WARN, Logger::ERROR,
    #   Logger::FATAL)
    # @return [Symbol] symbol representation of the logging level
    def self.from_logger_level(const)
      case const
      when Logger::DEBUG then :debug
      when Logger::INFO then :info
      when Logger::WARN then :warn
      when Logger::ERROR then :error
      else :fatal
      end
    end

    # Returns a new Hash with all key values coerced to symbols. All keys
    # within a Hash are coerced by calling #to_sym and hashes within arrays
    # and other hashes are traversed.
    #
    # @param obj [Object] the hash to be processed. While intended for
    #   hashes, this method safely processes arbitrary objects
    # @return [Object] a converted hash with all keys as symbols
    def self.symbolized_hash(obj)
      if obj.is_a?(Hash)
        obj.inject({}) { |h, (k, v)| h[k.to_sym] = symbolized_hash(v); h }
      elsif obj.is_a?(Array)
        obj.inject([]) { |a, e| a << symbolized_hash(e); a }
      else
        obj
      end
    end

    # Returns a new Hash with all key values coerced to strings. All keys
    # within a Hash are coerced by calling #to_s and hashes with arrays
    # and other hashes are traversed.
    #
    # @param obj [Object] the hash to be processed. While intended for
    #   hashes, this method safely processes arbitrary objects
    # @return [Object] a converted hash with all keys as strings
    def self.stringified_hash(obj)
      if obj.is_a?(Hash)
        obj.inject({}) { |h, (k, v)| h[k.to_s] = stringified_hash(v); h }
      elsif obj.is_a?(Array)
        obj.inject([]) { |a, e| a << stringified_hash(e); a }
      else
        obj
      end
    end

    # Returns a formatted string representing a duration in seconds.
    #
    # @param total [Integer] the total number of seconds
    # @return [String] a formatted string of the form (XmYY.00s)
    def self.duration(total)
      total = 0 if total.nil?
      minutes = (total / 60).to_i
      seconds = (total - (minutes * 60))
      format("(%dm%.2fs)", minutes, seconds)
    end

    # Generates a command (or series of commands) wrapped so that it can be
    # invoked on a remote instance or locally.
    #
    # This method uses the Bourne shell (/bin/sh) to maximize the chance of
    # cross platform portability on Unixlike systems.
    #
    # @param [String] the command
    # @return [String] a wrapped command string
    def self.wrap_command(cmd, shell = "bourne")
      cmd = "false" if cmd.nil?
      cmd = "true" if cmd.to_s.empty?
      
      case shell
      when "bourne"
        cmd = cmd.sub(/\n\Z/, "") if cmd =~ /\n\Z/

        "sh -c '\n#{cmd}\n'"
      when "powershell"
        # Do we need a wrapper for powershell
        cmd
      else 
        raise "[Util.shell_helpers] Unsupported shell: #{shell}"
      end
    end

    # Modifes the given string to strip leading whitespace on each line, the
    # amount which is calculated by using the first line of text.
    #
    # @example
    #
    #   string = <<-STRING
    #     a
    #       b
    #   c
    #   STRING
    #   Util.outdent!(string) # => "a\n  b\nc\n"
    #
    # @param string [String] the string that will be modified
    # @return [String] the modified string
    def self.outdent!(string)
      string.gsub!(/^ {#{string.index(/[^ ]/)}}/, "")
    end

    # Returns a set of Shell compatible helper
    # functions. This function is usually called inline in a string that
    # will be executed remotely on a test instance.
    #
    # @return [String] a string representation of useful helper functions
    def self.shell_helpers(shell = "bourne")
      case shell
      when "bourne"
        file = "download_helpers.sh"
      when "powershell"
        # No download helper for now.. 
        # Should we have one: file = "download_helpers.ps1"
        return ""
      else 
        raise "[Util.shell_helpers] Unsupported shell: #{shell}"
      end

      IO.read(File.join(
        File.dirname(__FILE__), %W[.. .. support #{file}]
      ))
    end
  end
end

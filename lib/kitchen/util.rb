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
        obj.inject({}) { |h, (k, v)| h[k.to_sym] = symbolized_hash(v) ; h }
      elsif obj.is_a?(Array)
        obj.inject([]) { |a, v| a << symbolized_hash(v) ; a }
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
        obj.inject({}) { |h, (k, v)| h[k.to_s] = stringified_hash(v) ; h }
      elsif obj.is_a?(Array)
        obj.inject([]) { |a, v| a << stringified_hash(v) ; a }
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
      "(%dm%.2fs)" % [minutes, seconds]
    end

    # Returns a set of Bourne Shell (AKA /bin/sh) compatible helper
    # functions. This function is usually called inline in a string that
    # will be executed remotely on a test instance.
    #
    # @return [String] a string representation of useful helper functions
    def self.shell_helpers
      <<-HELPERS
        # Check whether a command exists - returns 0 if it does, 1 if it does not
        exists() {
          if command -v $1 >/dev/null 2>&1
          then
            return 0
          else
            return 1
          fi
        }

        # do_wget URL FILENAME
        do_wget() {
          echo "trying wget..."
          wget -O "$2" "$1" 2>/tmp/stderr
          # check for bad return status
          test $? -ne 0 && return 1
          # check for 404 or empty file
          grep "ERROR 404" /tmp/stderr 2>&1 >/dev/null
          if test $? -eq 0 || test ! -s "$2"; then
            return 1
          fi
          return 0
        }

        # do_curl URL FILENAME
        do_curl() {
          echo "trying curl..."
          curl -L "$1" > "$2"
          # check for bad return status
          [ $? -ne 0 ] && return 1
          # check for bad output or empty file
          grep "The specified key does not exist." "$2" 2>&1 >/dev/null
          if test $? -eq 0 || test ! -s "$2"; then
            return 1
          fi
          return 0
        }

        # do_fetch URL FILENAME
        do_fetch() {
          echo "trying fetch..."
          fetch -o "$2" "$1" 2>/tmp/stderr
          # check for bad return status
          test $? -ne 0 && return 1
          return 0
        }

        # do_curl URL FILENAME
        do_perl() {
          echo "trying perl..."
          perl -e "use LWP::Simple; getprint($ARGV[0]);" "$1" > "$2"
          # check for bad return status
          test $? -ne 0 && return 1
          # check for bad output or empty file
          # grep "The specified key does not exist." "$2" 2>&1 >/dev/null
          # if test $? -eq 0 || test ! -s "$2"; then
          #   unable_to_retrieve_package
          # fi
          return 0
        }

        # do_curl URL FILENAME
        do_python() {
          echo "trying python..."
          python -c "import sys,urllib2 ; sys.stdout.write(urllib2.urlopen(sys.argv[1]).read())" "$1" > "$2"
          # check for bad return status
          test $? -ne 0 && return 1
          # check for bad output or empty file
          #grep "The specified key does not exist." "$2" 2>&1 >/dev/null
          #if test $? -eq 0 || test ! -s "$2"; then
          #  unable_to_retrieve_package
          #fi
          return 0
        }

        # do_download URL FILENAME
        do_download() {
          PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
          export PATH

          echo "downloading $1"
          echo "  to file $2"

          # we try all of these until we get success.
          # perl, in particular may be present but LWP::Simple may not be installed

          if exists wget; then
            do_wget $1 $2 && return 0
          fi

          if exists curl; then
            do_curl $1 $2 && return 0
          fi

          if exists fetch; then
            do_fetch $1 $2 && return 0
          fi

          if exists perl; then
            do_perl $1 $2 && return 0
          fi

          if exists python; then
            do_python $1 $2 && return 0
          fi

          echo ">>>>>> wget, curl, fetch, perl or python not found on this instance."
          return 16
        }
      HELPERS
    end
  end
end

#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module TestKitchen
  class UI

    attr_reader :stdout
    attr_reader :stderr
    attr_reader :stdin

    def initialize(stdout, stderr, stdin, config)
      @stdout, @stderr, @stdin, @config = stdout, stderr, stdin, config
    end

    def highline
      @highline ||= begin
        require 'highline'
        HighLine.new
      end
    end

    # Prints a message to stdout. Aliased as +info+ for compatibility with
    # the logger API.
    def msg(message, *colors)
      if colors
        message = color(message, *colors)
      end
      stdout.puts message
    end

    alias :info :msg

    # Prints a msg to stderr. Used for warn, error, and fatal.
    def err(message)
      stderr.puts message
    end

    # Print a warning message
    def warn(message)
      err("#{color('WARNING:', :yellow, :bold)} #{message}")
    end

    # Print an error message
    def error(message)
      err("#{color('ERROR:', :red, :bold)} #{message}")
    end

    # Print a message describing a fatal error.
    def fatal(message)
      err("#{color('FATAL:', :red, :bold)} #{message}")
    end

    def color(string, *colors)
      highline.color(string, *colors)
    end

  end
end

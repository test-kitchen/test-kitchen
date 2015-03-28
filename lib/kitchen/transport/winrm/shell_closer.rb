# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2015, Fletcher Nichol
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

  module Transport

    class Winrm < Kitchen::Transport::Base

      # An object that can close a remote shell session over WinRM.
      #
      # @author Fletcher Nichol <fnichol@nichol.ca>
      class ShellCloser

        # @return [String,nil] the identifier for the current open remote
        #   shell session
        attr_accessor :shell_id

        # Constructs a new ShellCloser.
        #
        # @param info [String] a string representation of the connection
        # @param debug [true,false] whether or not debug messages should be
        #   output
        # @param args [Array] arguments to construct a `WinRM::WinRMWebService`
        def initialize(info, debug, args)
          @info = info
          @debug = debug
          @args = args
        end

        # Closes the remote shell session.
        def call(*)
          debug("[CommandExecutor] closing remote shell #{@shell_id} on #{@info}")
          ::WinRM::WinRMWebService.new(*@args).close_shell(@shell_id)
          debug("[CommandExecutor] remote shell #{@shell_id} closed")
        rescue => e
          debug("Exception: #{e.inspect}")
        end

        def for(shell_id)
          self.class.new(@info, @debug, @args).tap { |c| c.shell_id = shell_id }
        end

        private

        # Writes a debug message, if debug mode is enabled.
        #
        # @param message [String] a message
        # @api private
        def debug(message)
          $stdout.puts "D      #{message}" if @debug
        end
      end
    end
  end
end

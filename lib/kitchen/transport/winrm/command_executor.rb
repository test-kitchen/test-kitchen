# -*- encoding: utf-8 -*-
#
# Author:: Matt Wrock (<matt@mattwrock.com>)
#
# Copyright (C) 2014, Matt Wrock
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

require "json"
require "ostruct"

require "kitchen/transport/winrm/template"

module Kitchen

  module Transport

    class Winrm < Kitchen::Transport::Base

      # Object which can execute multiple commands and Powershell scripts in
      # one shared remote shell session. The maximum number of commands per
      # shell is determined by interrogating the remote host when the session
      # is opened and the remote shell is automatically recycled before the
      # threshold is reached.
      #
      # @author Matt Wrock <matt@mattwrock.com>
      # @author Fletcher Nichol <fnichol@nichol.ca>
      class CommandExecutor

        # @return [Integer,nil] the safe maximum number of commands that can
        #   be executed in one remote shell session, or `nil` if the
        #   threshold has not yet been determined
        attr_reader :max_commands

        # @return [String,nil] the identifier for the current open remote
        #   shell session, or `nil` if the session is not open
        attr_reader :shell

        # Creates a CommandExecutor given a `WinRM::WinRMWebService` object.
        #
        # @param service [WinRM::WinRMWebService] a winrm web service object
        # @param logger [#debug,#info] an optional logger/ui object that
        #   responds to `#debug` and `#info` (default: `nil`)
        def initialize(service, logger = nil)
          @service        = service
          @logger         = logger
          @command_count  = 0
        end

        # Closes the open remote shell session. This method can be called
        # multiple times, even if there is no open session.
        def close
          return if shell.nil?

          service.close_shell(shell)
          @shell = nil
        end

        # Opens a remote shell session for reuse. The maxiumum
        # command-per-shell threshold is also determined the first time this
        # method is invoked and cached for later invocations.
        #
        # @return [String] the remote shell session indentifier
        def open
          close
          @shell = service.open_shell
          @command_count = 0
          determine_max_commands unless max_commands
          shell
        end

        # Runs a CMD command.
        #
        # @param command [String] the command to run on the remote system
        # @param arguments [Array<String>] arguments to the command
        # @yield [stdout, stderr] yields more live access the standard
        #   output and standard error streams as they are returns, if
        #   streaming behavior is desired
        # @return [WinRM::Output] output object with stdout, stderr, and
        #   exit code
        def run_cmd(command, arguments = [], &block)
          reset if command_count_exceeded?
          ensure_open_shell!

          @command_count += 1
          result = nil
          service.run_command(shell, command, arguments) do |command_id|
            result = service.get_command_output(shell, command_id, &block)
          end
          result
        end

        # Runs a series of Powershell commands in one Powershell session, using
        # `Invoke-Command` cmdlets. The resulting output object is augmented
        # with a `:results` key containing an Array of the return values of
        # `Invoke-Command` blocks which have return values.
        #
        # @example Running multiple commands
        #
        #   result = executor.run_invoke_commands do |builder|
        #     builder << "return $true"
        #     builder << "return $false"
        #   end
        #   result[:returns] # => ["True", "False"]
        #
        # @yield [commands] gives the Array of commands to the block so that
        #   additional commands can be appended
        # @return [WinRM::Output] output object with an additional `:results`
        #   key
        def run_invoke_commands
          commands = []
          yield commands
          return [] if commands.empty?

          @batch_template ||= Template.new(File.join(
            File.dirname(__FILE__),
            %W[.. .. .. .. support powershell_batch.ps1.erb]
          ))

          commands = commands.
            map { |entry| "$result += Invoke-Command { #{entry} }" }.join("\n")

          output = run_powershell_script(
            @batch_template % { :commands => commands })

          invoke_commands_response(output)
        end

        # Run a Powershell script that resides on the local box.
        #
        # @param script_file [IO,String] an IO reference for reading the
        #   Powershell script or the actual file contents
        # @yield [stdout, stderr] yields more live access the standard
        #   output and standard error streams as they are returns, if
        #   streaming behavior is desired
        # @return [WinRM::Output] output object with stdout, stderr, and
        #   exit code
        def run_powershell_script(script_file, &block)
          # this code looks overly compact in an attempt to limit local
          # variable assignments that may contain large strings and
          # consequently bloat the Ruby VM
          run_cmd(
            "powershell",
            [
              "-encodedCommand",
              WinRM::PowershellScript.new(
                script_file.is_a?(IO) ? script_file.read : script_file
              ).encoded
            ],
            &block
          )
        end

        private

        LEGACY_LIMIT = 15

        MODERN_LIMIT = 1500

        PS1_OS_VERSION = "[environment]::OSVersion.Version.tostring()".freeze

        # @return [Integer] the number of executed commands on the remote
        #   shell session
        # @api private
        attr_accessor :command_count

        # @return [#debug,#info] the logger
        # @api private
        attr_reader :logger

        # @return [WinRM::WinRMWebService] a WinRM web service object
        # @api private
        attr_reader :service

        # @return [true,false] whether or not the number of exeecuted commands
        #   have exceeded the maxiumum threshold
        # @api private
        def command_count_exceeded?
          command_count > max_commands.to_i
        end

        # Ensures that there is an open remote shell session.
        #
        # @raise [WinRM::WinRMError] if there is no open shell
        # @api private
        def ensure_open_shell!
          if shell.nil?
            raise WinRM::WinRMError, "#{self.class}#open must be called " \
              "before any run methods are invoked"
          end
        end

        # Determines the safe maximum number of commands that can be executed
        # on a remote shell session by interrogating the remote host.
        #
        # @api private
        def determine_max_commands
          os_version = run_powershell_script(PS1_OS_VERSION).stdout.chomp
          @max_commands = os_version < "6.2" ? LEGACY_LIMIT : MODERN_LIMIT
          @max_commands -= 2 # to be safe
        end

        # Parses the output of a script containing a `__JSON__` delimiter
        # and extracts the returns values from that JSON data.
        #
        # @param output [WinRM::Output] output object to augment
        # @return [WinRM::Output] output object with an additional `:results`
        #   key
        # @raise [WinRM::WinRMError] if the JSON document could not be parsed
        # @api private
        def invoke_commands_response(output)
          _, _, json = output.stdout.
            sub(",\r\n}", "\n}").partition("__JSON__\r\n")

          output[:returns] = JSON.parse(json).to_a.
            sort { |a, b| a.first <=> b.first }.map(&:last)

          output
        rescue JSON::JSONError => e
          raise WinRM::WinRMError,
            "Failed to parse JSON in response: #{e.inspect} for #{json}"
        end

        # Closes the remote shell session and opens a new one.
        #
        # @api private
        def reset
          logger.debug("[#{self.class}] Resetting WinRM shell " \
            "(Max command limit is #{max_commands})") if logger
          open
        end
      end
    end
  end
end

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

require "base64"

module Kitchen

  module Transport

    class Winrm < Kitchen::Transport::Base

      # TODO: comment
      class CommandExecutor

        attr_reader :max_commands

        attr_reader :shell

        def initialize(service, logger = nil)
          @service        = service
          @logger         = logger
          @command_count  = 0
        end

        def close
          return if shell.nil?

          service.close_shell(shell)
          @shell = nil
        end

        def open
          close
          @shell = service.open_shell
          @command_count = 0
          determine_max_commands unless max_commands
          shell
        end

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

        def run_powershell_script(script_file, &block)
          text = script_file.is_a?(IO) ? script_file.read : script_file
          script = WinRM::PowershellScript.new(text)
          run_cmd("powershell", ["-encodedCommand", script.encoded], &block)
        end

        private

        LEGACY_LIMIT = 15

        MODERN_LIMIT = 1500

        PS1_OS_VERSION = "[environment]::OSVersion.Version.tostring()".freeze

        attr_accessor :command_count

        attr_reader :logger

        attr_reader :service

        def command_count_exceeded?
          command_count > max_commands.to_i
        end

        def ensure_open_shell!
          if shell.nil?
            raise WinRM::WinRMError, "#{self.class}#open must be called " \
              "before any run methods are invoked"
          end
        end

        def determine_max_commands
          os_version = run_powershell_script(PS1_OS_VERSION).stdout.chomp
          @max_commands = os_version < "6.2" ? LEGACY_LIMIT : MODERN_LIMIT
          @max_commands -= 2 # to be safe
        end

        def reset
          logger.debug("[#{self.class}] Resetting WinRM shell " \
            "(Max command limit is #{max_commands})") if logger
          open
        end
      end
    end
  end
end

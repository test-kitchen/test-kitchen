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

module Kitchen
  module Transport
    module WinRMFileTransfer

      # A shell that holds the state of a single winrm connection
      # Windows 7 and Server 2008 R2 by default are allowed no more
      # than 15 commands per session. So we reset the session whenever
      # this threshold is reached.
      #
      # @author Matt Wrock <matt@mattwrock.com>
      class Shell
        def initialize(logger, service)
          @logger = logger
          @service = service
          @shell = reset
          os_version = powershell("[environment]::OSVersion.Version.tostring()")
          os_version < "6.2" ? @op_limit = 15 : @op_limit = 1500
          @op_limit -= 2 # to be safe
        end

        def powershell(script)
          script = "$ProgressPreference='SilentlyContinue';" + script
          @logger.debug("executing powershell script: \n#{script}")
          script = script.encode("UTF-16LE", "UTF-8")
          script = Base64.strict_encode64(script)
          cmd("powershell", ["-encodedCommand", script])
        end

        def cmd(command, arguments = [])
          check_op_count!

          out_stream = []
          err_stream = []
          @op_count += 1
          command_id = @service.run_command(@shell, command, arguments)
          command_output = @service.get_command_output(@shell, command_id) do |stdout, stderr|
            out_stream << stdout if stdout
            err_stream << stderr if stderr
          end
          @service.cleanup_command(@shell, command_id)

          if !command_output[:exitcode].zero? || !err_stream.empty?
            raise TransportFailed, :message => command_output.inspect
          end
          out_stream.join.chomp
        end

        def close
          @service.close_shell(@shell)
        end

        private

        def reset
          close unless @shell.nil?
          @shell = @service.open_shell
          @op_count = 0
          @logger.debug("resetting winrm shell curent operation limit is #{@op_limit}")
          @shell
        end

        def check_op_count!
          return if @op_limit.nil?
          reset if @op_count > @op_limit
        end
      end
    end
  end
end

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

require 'mixlib/shellout'

module Kitchen

  # Mixin that wraps a command shell out invocation, providing a #run_command
  # method.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  module ShellOut

    # Wrapped exception for any interally raised shell out commands.
    class ShellCommandFailed < TransientFailure ; end

    # Executes a command in a subshell on the local running system.
    #
    # @param cmd [String] command to be executed locally
    # @param use_sudo [TrueClass, FalseClass] whether or not to use sudo
    # @param log_subject [String] used in the output or log header for clarity
    #   and context
    # @raise [ShellCommandFailed] if the command fails
    # @raise [Error] for all other unexpected exceptions
    def run_command(cmd, use_sudo = false, log_subject = "local")
      cmd = "sudo #{cmd}" if use_sudo
      subject = "[#{log_subject} command]"

      info("#{subject} BEGIN (#{display_cmd(cmd)})")
      sh = Mixlib::ShellOut.new(cmd, :live_stream => logger, :timeout => 60000)
      sh.run_command
      info("#{subject} END #{Util.duration(sh.execution_time)}")
      sh.error!
    rescue Mixlib::ShellOut::ShellCommandFailed => ex
      raise ShellCommandFailed, ex.message
    rescue Exception => error
      error.extend(Kitchen::Error)
      raise
    end

    private

    def display_cmd(cmd)
      first_line, newline, rest = cmd.partition("\n")
      last_char = cmd[cmd.size - 1]

      newline == "\n" ? "#{first_line}\\n...#{last_char}" : cmd
    end
  end
end

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

require "mixlib/shellout"

module Kitchen

  # Mixin that wraps a command shell out invocation, providing a #run_command
  # method.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  module ShellOut

    # Wrapped exception for any interally raised shell out commands.
    class ShellCommandFailed < TransientFailure; end

    # Executes a command in a subshell on the local running system.
    #
    # @param cmd [String] command to be executed locally
    # @param options [Hash] additional configuration of command
    # @option options [TrueClass, FalseClass] :use_sudo whether or not to use
    #   sudo
    # @option options [String] :sudo_command custom sudo command to use.
    #   Default is "sudo -E".
    # @option options [String] :log_subject used in the output or log header
    #   for clarity and context. Default is "local".
    # @option options [String] :cwd the directory to chdir to before running
    #   the command
    # @option options [Hash] :environment a Hash of environment variables to
    #   set before the command is run. By default, the environment will
    #   *always* be set to `'LC_ALL' => 'C'` to prevent issues with multibyte
    #   characters in Ruby 1.8. To avoid this, use :environment => nil for
    #   *no* extra environment settings, or
    #   `:environment => {'LC_ALL'=>nil, ...}` to set other environment
    #   settings without changing the locale.
    # @option options [Integer] :timeout Numeric value for the number of
    #   seconds to wait on the child process before raising an Exception.
    #   This is calculated as the total amount of time that ShellOut waited on
    #   the child process without receiving any output (i.e., IO.select
    #   returned nil). Default is 60000 seconds. Note: the stdlib Timeout
    #   library is not used.
    # @return [String] the standard output of the command as a String
    # @raise [ShellCommandFailed] if the command fails
    # @raise [Error] for all other unexpected exceptions
    def run_command(cmd, options = {})
      if options.fetch(:use_sudo, false)
        cmd = "#{options.fetch(:sudo_command, "sudo -E")} #{cmd}"
      end
      subject = "[#{options.fetch(:log_subject, "local")} command]"

      debug("#{subject} BEGIN (#{cmd})")
      sh = Mixlib::ShellOut.new(cmd, shell_opts(options))
      sh.run_command
      debug("#{subject} END #{Util.duration(sh.execution_time)}")
      sh.error!
      sh.stdout
    rescue Mixlib::ShellOut::ShellCommandFailed => ex
      raise ShellCommandFailed, ex.message
    rescue Exception => error # rubocop:disable Lint/RescueException
      error.extend(Kitchen::Error)
      raise
    end

    private

    # Returns a hash of MixLib::ShellOut options for the command.
    #
    # @param options [Hash] a Hash of options
    # @return [Hash] a new Hash of options, filterd and merged with defaults
    # @api private
    def shell_opts(options)
      filtered_opts = options.reject do |key, _value|
        [:use_sudo, :sudo_command, :log_subject, :quiet].include?(key)
      end
      { :live_stream => logger, :timeout => 60000 }.merge(filtered_opts)
    end
  end
end

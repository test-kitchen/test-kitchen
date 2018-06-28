# -*- encoding: utf-8 -*-
#
# Author:: Noah Kantrowitz <noah@coderanger.net>
#
# Copyright (C) 2018, Noah Kantrowitz
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

require "kitchen/errors"
require "kitchen/shell_out"

module Kitchen
  # A helper object used by {Instance} to coordinate lifecycle hook calls from
  # the `lifecycle:` configuration section.
  #
  # @api internal
  # @since 1.22
  class LifecycleHooks
    include Configurable
    include Logging
    include ShellOut

    def initialize(config)
      init_config(config)
    end

    # Run a lifecycle phase with the pre and post hooks.
    #
    # @param phase [String] Lifecycle phase which is being executed.
    # @param state_file [StateFile] Instance state file object.
    # @param block [Proc] Block of code implementing the lifecycle phase.
    # @return [void]
    def run_with_hooks(phase, state_file, &block)
      run(instance, phase, state_file, :pre)
      yield
      run(instance, phase, state_file, :post)
    end

    # Execute a specific lifecycle hook.
    #
    # @param instance [Instance] The instance object to run against.
    # @param phase [String] Lifecycle phase which is being executed.
    # @param state_file [StateFile] Instance state file object.
    # @param hook_timing [Symbol] `:pre` or `:post` to indicate which hook to run.
    # @return [void]
    def run(instance, phase, state_file, hook_timing)
      # Yes this has to be a symbol because of how data munger works.
      hook_key = :"#{hook_timing}_#{phase}"
      # No hooks? We're outta here.
      hook_data = Array(config[hook_key])
      return if hook_data.empty?
      state = nil
      hook_data.each do |hook|
        # Coerce the common case of a bare string to be a local command. This
        # is to match the behavior of the old `pre_create_command` semi-hook.
        hook = { local: hook } if hook.is_a?(String)
        if hook.include?(:local)
          # Local command execution on the workstation.
          cmd = hook.delete(:local)
          run_command(cmd, hook)
        elsif hook.include?(:remote)
          # Remote command execution on the test instance.
          cmd = hook.delete(:remote)
          # At least make a token effort to read this file less often.
          state ||= state_file.read
          conn = instance.transport.connection(state)
          conn.execute(cmd)
        else
          raise UserError, "Unknown lifecycle hook target #{hook.inspect}"
        end
      end
    end
  end
end

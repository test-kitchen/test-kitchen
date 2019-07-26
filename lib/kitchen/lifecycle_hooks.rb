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

    private

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

      hook_data.each do |hook|
        # Coerce the common case of a bare string to be a local command. This
        # is to match the behavior of the old `pre_create_command` semi-hook.
        hook = { local: hook } if hook.is_a?(String)
        if hook.include?(:local)
          # Local command execution on the workstation.
          run_local_hook(instance, state_file, hook)
        elsif hook.include?(:remote)
          # Remote command execution on the test instance.
          run_remote_hook(instance, state_file, hook)
        else
          raise UserError, "Unknown lifecycle hook target #{hook.inspect}"
        end
      end
    end

    # Execute a specific local command hook.
    #
    # @param instance [Instance] The instance object to run against.
    # @param state_file [StateFile] Instance state file object.
    # @param hook [Hash] Hook configration to use.
    # @return [void]
    def run_local_hook(instance, state_file, hook)
      cmd = hook.fetch(:local)
      state = state_file.read
      # set up empty user variable
      user = {}
      # Set up some environment variables with instance info.
      environment = {
        "KITCHEN_INSTANCE_NAME" => instance.name,
        "KITCHEN_SUITE_NAME" => instance.suite.name,
        "KITCHEN_PLATFORM_NAME" => instance.platform.name,
        "KITCHEN_INSTANCE_HOSTNAME" => state[:hostname].to_s,
      }
      # If the user specified env vars too, fix them up because symbol keys
      # make mixlib-shellout sad.
      if hook[:environment]
        hook[:environment].each do |k, v|
          environment[k.to_s] = v.to_s
        end
      end

      # add user to user hash for later merging
      if hook[:user]
        user[:user] = hook[:user]
      end

      # Default the cwd to the kitchen root and resolve a relative input cwd against that.
      cwd = if hook[:cwd]
              File.expand_path(hook[:cwd], config[:kitchen_root])
            else
              config[:kitchen_root]
            end
      # Build the options for mixlib-shellout.
      opts = {}.merge(user).merge(cwd: cwd, environment: environment)
      run_command(cmd, opts)
    end

    # Execute a specific remote command hook.
    #
    # @param instance [Instance] The instance object to run against.
    # @param state_file [StateFile] Instance state file object.
    # @param hook [Hash] Hook configration to use.
    # @return [void]
    def run_remote_hook(instance, state_file, hook)
      # Check if we're in a state that makes sense to even try.
      unless instance.last_action
        if hook[:skippable]
          # Just not even trying.
          return
        else
          raise UserError, "Cannot use remote lifecycle hooks during phases when the instance is not available"
        end
      end

      cmd = hook.fetch(:remote)
      conn = instance.transport.connection(state_file.read)
      conn.execute(cmd)
    end
  end
end

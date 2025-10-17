#
# Author:: Noah Kantrowitz <noah@coderanger.net>
#
# Copyright (C) 2018, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "configurable"
require_relative "errors"
require_relative "lifecycle_hook/local"
require_relative "lifecycle_hook/remote"
require_relative "logging"

module Kitchen
  # A helper object used by {Instance} to coordinate lifecycle hook calls from
  # the `lifecycle:` configuration section.
  #
  # @api internal
  # @since 1.22
  class LifecycleHooks
    include Configurable
    include Logging

    def initialize(config, state_file)
      init_config(config)
      @state_file = state_file
    end

    # Run a lifecycle phase with the pre and post hooks.
    #
    # @param phase [String] Lifecycle phase which is being executed.
    # @param state_file [StateFile] Instance state file object.
    # @param block [Proc] Block of code implementing the lifecycle phase.
    # @return [void]
    def run_with_hooks(phase, state_file, &block)
      run(phase, :pre)
      yield
      run(phase, :post)
    ensure
      run(phase, :finally)
    end

    # @return [Kitchen::StateFile]
    attr_reader :state_file

    private

    # Execute a specific lifecycle hook.
    #
    # @param phase [String] Lifecycle phase which is being executed.
    # @param hook_timing [Symbol] `:pre`, `:post`, or `:finally` to indicate which hook to run.
    # @return [void]
    def run(phase, hook_timing)
      # Yes this has to be a symbol because of how data munger works.
      hook_key = :"#{hook_timing}_#{phase}"
      # No hooks? We're outta here.
      hook_data = Array(config[hook_key])
      return if hook_data.empty?

      hook_data.each do |hook|
        # Coerce the common case of a bare string to be a local command. This
        # is to match the behavior of the old `pre_create_command` semi-hook.
        hook = { local: hook } if hook.is_a?(String)
        hook = generate_hook(phase, hook)
        hook.run if hook.should_run?
      end
    end

    # @param phase [String]
    # @param hook [Hash]
    # @return [Kitchen::LifecycleHook::Local, Kitchen::LifecycleHook::Remote]
    def generate_hook(phase, hook)
      if hook.include?(:local)
        # Local command execution on the workstation.
        Kitchen::LifecycleHook::Local.new(self, phase, hook)
      elsif hook.include?(:remote)
        # Remote command execution on the test instance.
        Kitchen::LifecycleHook::Remote.new(self, phase, hook)
      else
        raise UserError, "Unknown lifecycle hook target #{hook.inspect}"
      end
    end
  end
end

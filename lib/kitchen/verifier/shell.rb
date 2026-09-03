#
# Author:: SAWANOBORI Yukihiko (<sawanoboriyu@higanworks.com>)
#
# Copyright (C) 2015, HiganWorks LLC
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

require_relative "base"

module Kitchen
  module Verifier
    # Shell verifier for Kitchen. This verifier just executes a shell command locally.
    #
    # @author SAWANOBORI Yukihiko (<sawanoboriyu@higanworks.com>)
    class Shell < Kitchen::Verifier::Base
      require "mixlib/shellout" unless defined?(Mixlib::ShellOut)

      kitchen_verifier_api_version 1

      plugin_version Kitchen::VERSION

      default_config :sleep, 0
      default_config :command, "true"
      default_config :shellout_opts, {}
      default_config :live_stream, $stdout
      default_config :remote_exec, false

      # (see Base#call)
      def call(state)
        info("[#{name}] Verify on instance #{instance.name} with state=#{state}")
        sleep_if_set
        if config[:remote_exec]
          instance.transport.connection(state) do |conn|
            conn.execute(config[:command])
          end
        else
          shellout(state)
        end
        debug("[#{name}] Verify completed.")
      end

      # for legacy drivers.
      def run_command
        if config[:remote_exec]
          config[:command]
        else
          shellout
          nil
        end
      end

      private

      # Sleep for a period of time, if a value is set in the config.
      #
      # @api private
      def sleep_if_set
        config[:sleep].to_i.times do
          info(".")
          sleep 1
        end
      end

      def shellout(state = {})
        cmd = Mixlib::ShellOut.new(config[:command], shellout_opts(state))
        cmd.live_stream = config[:live_stream]
        cmd.run_command
        begin
          cmd.error!
        rescue Mixlib::ShellOut::ShellCommandFailed
          raise ActionFailed, "Action #verify failed for #{instance.to_str}."
        end
      end

      # Returns the options to run the command with: whatever the user
      # configured, with the KITCHEN_* variables merged into their environment
      # rather than replacing it.
      #
      # This builds a new Hash instead of writing back to config. Nested config
      # hashes are shared between every instance, so mutating :shellout_opts
      # would leak one instance's environment into the others.
      #
      # @param state [Hash] mutable instance state
      # @return [Hash] options for Mixlib::ShellOut
      # @api private
      def shellout_opts(state)
        opts = config[:shellout_opts].to_h
        opts.merge(
          environment: opts.fetch(:environment, {}).to_h.merge(kitchen_environment(state))
        )
      end

      # @param state [Hash] mutable instance state
      # @return [Hash] the KITCHEN_* environment variables for this instance
      # @api private
      def kitchen_environment(state)
        env = {
          "KITCHEN_INSTANCE" => instance.name,
          "KITCHEN_PLATFORM" => instance.platform.name,
          "KITCHEN_SUITE" => instance.suite.name,
        }
        env["KITCHEN_USERNAME"] = instance.transport[:username] if instance.respond_to?(:transport)
        state.each_pair do |key, value|
          env["KITCHEN_" + key.to_s.upcase] = value.to_s
        end
        env
      end
    end
  end
end

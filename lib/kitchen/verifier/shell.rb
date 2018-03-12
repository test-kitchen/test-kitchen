# -*- encoding: utf-8 -*-
#
# Author:: SAWANOBORI Yukihiko (<sawanoboriyu@higanworks.com>)
#
# Copyright (C) 2015, HiganWorks LLC
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

require "kitchen/verifier/base"

module Kitchen
  module Verifier
    # Shell verifier for Kitchen. This verifier just execute shell command from local.
    #
    # @author SAWANOBORI Yukihiko (<sawanoboriyu@higanworks.com>)
    class Shell < Kitchen::Verifier::Base
      require "mixlib/shellout"

      kitchen_verifier_api_version 1

      plugin_version Kitchen::VERSION

      default_config :sleep, 0
      default_config :command, "true"
      default_config :environment, {}
      default_config :shellout_opts, {}
      default_config :live_stream, $stdout
      default_config :remote_exec, false

      # (see Base#call)
      def call(state)
        info("[#{name}] Verify on instance #{instance.name} with state=#{state}")
        sleep_if_set
        @merged_environment = state_to_env(state).merge(config[:environment] || {})

        if config[:remote_exec]
          begin
            instance.transport.connection(state) do |conn|
              conn.execute(remote_command)
            end
          rescue Kitchen::Transport::TransportFailed => ex
            raise ActionFailed, ex.message
          end
        else
          shellout
        end
        debug("[#{name}] Verify completed.")
      end

      private

      attr_reader :merged_environment

      # Sleep for a period of time, if a value is set in the config.
      #
      # @api private
      def sleep_if_set
        config[:sleep].to_i.times do
          info(".")
          sleep 1
        end
      end

      def shellout_opts
        config[:shellout_opts].dup.tap do |options|
          options[:environment] = merged_environment.merge(options[:environment] || {})
        end
      end

      def shellout
        cmd = Mixlib::ShellOut.new(config[:command], shellout_opts)
        cmd.live_stream = config[:live_stream]
        cmd.run_command
        begin
          cmd.error!
        rescue Mixlib::ShellOut::ShellCommandFailed
          raise ActionFailed, "Action #verify failed for #{instance.to_str}."
        end
      end

      def remote_command
        command = "env"
        merged_environment.each { |k, v| command << " #{k}='#{v.gsub("'", "'\"'\"'")}'" }
        command << " " << config[:command]
      end

      def state_to_env(state)
        {}.tap do |env|
          env["TEST_KITCHEN"] = "1"
          env["KITCHEN_INSTANCE"] = instance.name
          env["KITCHEN_PLATFORM"] = instance.platform.name
          env["KITCHEN_SUITE"] = instance.suite.name
          state.each_pair do |key, value|
            env["KITCHEN_" + key.to_s.upcase] = value.to_s
          end
        end
      end
    end
  end
end

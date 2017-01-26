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
      default_config :shellout_opts, {}
      default_config :live_stream, $stdout
      default_config :remote_exec, false
      default_config :transfer_files, false

      # (see Base#call)
      def call(state)
        info("[#{name}] Verify on instance=#{instance} with state=#{state}")
        sleep_if_set
        merge_state_to_env(state)
        if config[:transfer_files]
          create_sandbox
          sandbox_dirs = Dir.glob(File.join(sandbox_path, "*"))
          begin
            instance.transport.connection(state) do |conn|
              conn.execute(install_command)
              conn.execute(init_command)
              info("Transferring files to #{instance.to_str}")
              conn.upload(sandbox_dirs, config[:root_path])
              debug("Transfer complete")
            end
          rescue Kitchen::Transport::TransportFailed => ex
            raise ActionFailed, ex.message
          ensure
            cleanup_sandbox
          end
        end
        if config[:remote_exec]
          instance.transport.connection(state) do |conn|
            conn.execute(config[:command])
          end
        else
          shellout
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

      # (see Base#create_sandbox)
      def create_sandbox
        super
        prepare_helpers
        prepare_suites
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

      def shellout
        cmd = Mixlib::ShellOut.new(config[:command], config[:shellout_opts])
        cmd.live_stream = config[:live_stream]
        cmd.run_command
        begin
          cmd.error!
        rescue Mixlib::ShellOut::ShellCommandFailed
          raise ActionFailed, "Action #verify failed for #{instance.to_str}."
        end
      end

      def merge_state_to_env(state)
        env_state = { environment: {} }
        env_state[:environment]["KITCHEN_INSTANCE"] = instance.name
        env_state[:environment]["KITCHEN_PLATFORM"] = instance.platform.name
        env_state[:environment]["KITCHEN_SUITE"] = instance.suite.name
        state.each_pair do |key, value|
          env_state[:environment]["KITCHEN_" + key.to_s.upcase] = value.to_s
        end
        config[:shellout_opts].merge!(env_state)
      end

      # Returns an Array of test suite filenames for the related suite currently
      # residing on the local workstation. No files are excluded.
      #
      # @return [Array<String>] array of suite files
      # @api private
      def local_suite_files
        glob = File.join(config[:test_base_path], config[:suite_name], "*/**/*")
        Dir.glob(glob).reject { |f| File.directory?(f) }
      end
    end
  end
end

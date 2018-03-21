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
      default_config :sudo, false # 'false' for backwards compatability

      # (see Base#call)
      def call(state)
        info("[#{name}] Verify on instance #{instance.name} with state=#{state}")
        sleep_if_set
        @merged_environment = state_to_env(state).merge(config[:environment] || {})

        if config[:remote_exec]
          super
        else
          shellout
        end
        debug("[#{name}] Verify completed.")
      end

      # (see Base#create_sandbox)
      def create_sandbox
        super
        prepare_helpers
        prepare_suite
      end

      # (see Base#run_command)
      def run_command
        if config[:remote_exec]
          remote_command
        else
          warn "Legacy call to Shell Verifier #run_command detected.  Do not call this method directly."
          shellout
          nil
        end
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

      # Merges environment variables with :shellout_opts as specified in the config
      #
      # @return [Hash] options to be passed to shellout
      # @api private
      def shellout_opts
        config[:shellout_opts].dup.tap do |options|
          options[:environment] = merged_environment.merge(options[:environment] || {})
        end
      end

      # Wraps command as necessary to honor Base options (proxy, sudo, command_prefix)
      #
      # @api private
      def build_command(command)
        prefix_command(wrap_shell_code(sudo(command)))
      end

      # Executes ShellOut with the appropriate options
      #
      # @api private
      def shellout
        cmd = Mixlib::ShellOut.new(build_command(config[:command]), shellout_opts)
        cmd.live_stream = config[:live_stream]
        cmd.run_command
        begin
          cmd.error!
        rescue Mixlib::ShellOut::ShellCommandFailed
          raise ActionFailed, "Action #verify failed for #{instance.to_str}."
        end
      end

      # Wraps and prepares config[:command] as necessary for remote execution
      #
      # @return [String] command to be executed remotely
      # @api private
      def remote_command
        command = Dir.exist?(sandbox_suites_dir) ? "cd #{config[:root_path]}\n" : ""
        merged_environment.each { |k, v| command << shell_env_var(k, v.gsub('"', '\\"')) << "\n" }
        command << build_command(config[:command])
      end

      # Merges primary environment settings with settings calculated from the state
      #
      # @return [Hash] system environment
      # @api private
      def state_to_env(state)
        {}.tap do |env|
          env["KITCHEN_INSTANCE"] = instance.name
          env["KITCHEN_PLATFORM"] = instance.platform.name
          env["KITCHEN_SUITE"] = instance.suite.name
          state.each_pair do |key, value|
            env["KITCHEN_" + key.to_s.upcase] = value.to_s
          end
        end
      end

      # Returns an Array of common helper filenames currently residing on the
      # local workstation.
      #
      # @return [Array<String>] array of helper files
      # @api private
      def helper_files
        Util.safe_glob(File.join(config[:test_base_path], "helpers"), "**/*").reject { |f| File.directory?(f) }
      end

      # Returns an Array of test suite filenames for the related suite currently
      # residing on the local workstation.
      #
      # @return [Array<String>] array of suite files
      # @api private
      def local_suite_files
        Util.safe_glob(File.join(config[:test_base_path], config[:suite_name]), "**/*").reject { |f| File.directory?(f) }
      end

      # Copies all common testing helper files into the suites directory in
      # the sandbox.
      #
      # @api private
      def prepare_helpers
        base = File.join(config[:test_base_path], "helpers")

        helper_files.each do |src|
          dest = File.join(sandbox_suites_dir, src.sub("#{base}/", ""))
          FileUtils.mkdir_p(File.dirname(dest))
          FileUtils.cp(src, dest, preserve: true)
        end
      end

      # Copies all test suite files into the suites directory in the sandbox.
      #
      # @api private
      def prepare_suite
        base = File.join(config[:test_base_path], config[:suite_name])

        local_suite_files.each do |src|
          dest = File.join(sandbox_suites_dir, src.sub("#{base}/", ""))
          FileUtils.mkdir_p(File.dirname(dest))
          FileUtils.cp(src, dest, preserve: true)
        end
      end

      # @return [String] path to suites directory under sandbox path
      # @api private
      def sandbox_suites_dir
        File.join(sandbox_path, "suites")
      end

    end
  end
end

#
# Author:: Chris Lundquist (<chris.lundquist@github.com>)
#
# Copyright (C) 2013, Chris Lundquist
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

require "shellwords" unless defined?(Shellwords)

require_relative "base"
require_relative "../version"

module Kitchen
  module Provisioner
    # Basic shell provisioner.
    #
    # @author Chris Lundquist (<chris.ludnquist@github.com>)
    class Shell < Base
      kitchen_provisioner_api_version 2

      plugin_version Kitchen::VERSION

      default_config :script do |provisioner|
        src = provisioner.powershell_shell? ? "bootstrap.ps1" : "bootstrap.sh"
        provisioner.calculate_path(src, type: :file)
      end
      expand_path_for :script

      # Run a single command instead of managing and running a script.
      default_config :command, nil

      # Add extra arguments to the converge script.
      default_config :arguments, []

      default_config :data_path do |provisioner|
        provisioner.calculate_path("data")
      end
      expand_path_for :data_path

      # (see Base#create_sandbox)
      def create_sandbox
        super
        prepare_data
        prepare_script
      end

      # (see Base#init_command)
      def init_command
        return nil if config[:command]

        root = config[:root_path]
        data = remote_path_join(root, "data")

        code = if powershell_shell?
                 Util.outdent!(<<-POWERSHELL)
            if (Test-Path "#{data}") {
              Remove-Item "#{data}" -Recurse -Force
            }
            if (-Not (Test-Path "#{root}")) {
              New-Item "#{root}" -ItemType directory | Out-Null
            }
                 POWERSHELL
               else
                 "#{sudo("rm")} -rf #{data} ; mkdir -p #{root}"
               end

        prefix_command(wrap_shell_code(code))
      end

      # (see Base#prepare_command)
      def prepare_command
        # On a windows host, the supplied script does not get marked as executable
        # due to windows not having the concept of an executable flag
        #
        # When the guest instance is *nix, `chmod +x` the script in the guest, prior to executing
        return unless unix_os? && config[:script] && !config[:command]

        debug "Marking script as executable"
        script = remote_path_join(
          config[:root_path],
          File.basename(config[:script])
        )
        prefix_command(wrap_shell_code(sudo("chmod +x #{script}")))
      end

      # (see Base#run_command)
      def run_command
        return prefix_command(wrap_shell_code(config[:command])) if config[:command]
        return unless config[:script]

        script = remote_path_join(
          config[:root_path],
          File.basename(config[:script])
        )

        if config[:arguments] && !config[:arguments].empty?
          if config[:arguments].is_a?(Array)
            if powershell_shell?
              script = ([script] + config[:arguments]).join(" ")
            else
              script = Shellwords.join([script] + config[:arguments])
            end
          else
            script.concat(" ").concat(config[:arguments].to_s)
          end
        end

        code = powershell_shell? ? %{& #{script}} : sudo(script)

        prefix_command(wrap_shell_code(code))
      end

      private

      # Creates a data directory in the sandbox directory, if a data directory
      # can be found and copies in the tree.
      #
      # @api private
      def prepare_data
        return unless config[:data_path]

        info("Preparing data")
        debug("Using data from #{config[:data_path]}")

        tmpdata_dir = File.join(sandbox_path, "data")
        FileUtils.mkdir_p(tmpdata_dir)
        FileUtils.cp_r(Util.list_directory(config[:data_path]), tmpdata_dir)
      end

      # Copies the executable script to the sandbox directory or creates a
      # stub script if one cannot be found.
      #
      # @api private
      def prepare_script
        info("Preparing script")

        if config[:script]
          debug("Using script from #{config[:script]}")
          FileUtils.cp_r(config[:script], sandbox_path)
        else
          info("No provisioner script file specified, skipping")
        end
      end
    end
  end
end

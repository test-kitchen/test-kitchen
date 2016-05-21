# -*- encoding: utf-8 -*-
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

require "kitchen/provisioner/base"
require "kitchen/version"

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
        provisioner.calculate_path(src, :type => :file)
      end
      expand_path_for :script

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

        wrap_shell_code(code)
      end

      # (see Base#run_command)
      def run_command
        script = remote_path_join(
          config[:root_path],
          File.basename(config[:script])
        )
        code = powershell_shell? ? %{& "#{script}"} : sudo(script)

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
        FileUtils.cp_r(Dir.glob("#{config[:data_path]}/*"), tmpdata_dir)
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
          prepare_stubbed_script
        end

        FileUtils.chmod(0755,
          File.join(sandbox_path, File.basename(config[:script])))
      end

      # Creates a minimal, no-op script in the sandbox path.
      #
      # @api private
      def prepare_stubbed_script
        base = powershell_shell? ? "bootstrap.ps1" : "bootstrap.sh"
        config[:script] = File.join(sandbox_path, base)
        info("#{File.basename(config[:script])} not found " \
          "so Kitchen will run a stubbed script. Is this intended?")
        File.open(config[:script], "wb") do |file|
          if powershell_shell?
            file.write(%{Write-Host "NO BOOTSTRAP SCRIPT PRESENT`n"\n})
          else
            file.write(%{#!/bin/sh\necho "NO BOOTSTRAP SCRIPT PRESENT"\n})
          end
        end
      end
    end
  end
end

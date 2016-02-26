# -*- encoding: utf-8 -*-
#
# Author:: SAWANOBORI Yukihiko <sawanoboriyu@higanworks.com>)
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

# Usage:
#
# puts your recipes to` apply/` directory.
#
# An example of .kitchen.yml.
#
# ---
# driver:
#   name: vagrant
#
# provisioner:
#   name: chef_apply
#
# platforms:
#   - name: ubuntu-12.04
#   - name: centos-6.4
#
# suites:
#   - name: default
#     run_list:
#       - recipe1
#       - recipe2
#
#
# The chef-apply runs twice below.
#
# chef-apply apply/recipe1.rb
# chef-apply apply/recipe2.rb

require "kitchen/provisioner/chef_base"

module Kitchen

  module Provisioner

    # Chef Apply provisioner.
    #
    # @author SAWANOBORI Yukihiko <sawanoboriyu@higanworks.com>)
    class ChefApply < ChefBase

      kitchen_provisioner_api_version 2

      plugin_version Kitchen::VERSION

      default_config :chef_apply_path do |provisioner|
        provisioner.
          remote_path_join(%W[#{provisioner[:chef_omnibus_root]} bin chef-apply]).
          tap { |path| path.concat(".bat") if provisioner.windows_os? }
      end

      default_config :apply_path do |provisioner|
        provisioner.calculate_path("apply")
      end
      expand_path_for :apply_path

      # (see ChefBase#create_sandbox)
      def create_sandbox
        @sandbox_path = Dir.mktmpdir("#{instance.name}-sandbox-")
        File.chmod(0755, sandbox_path)
        info("Preparing files for transfer")
        debug("Creating local sandbox in #{sandbox_path}")

        prepare_json
        prepare(:apply)
      end

      # (see ChefBase#init_command)
      def init_command
        dirs = %w[
          apply
        ].sort.map { |dir| remote_path_join(config[:root_path], dir) }

        vars = if powershell_shell?
          init_command_vars_for_powershell(dirs)
        else
          init_command_vars_for_bourne(dirs)
        end

        prefix_command(shell_code_from_file(vars, "chef_base_init_command"))
      end

      # (see ChefSolo#run_command)
      def run_command
        level = config[:log_level]
        lines = []
        config[:run_list].map do |recipe|
          cmd = sudo(config[:chef_apply_path]).dup.
            tap { |str| str.insert(0, "& ") if powershell_shell? }
          args = [
            "apply/#{recipe}.rb",
            "--log_level #{level}",
            "--no-color"
          ]
          args << "--logfile #{config[:log_file]}" if config[:log_file]

          lines << wrap_shell_code(
            [cmd, *args].join(" ").
            tap { |str| str.insert(0, reload_ps1_path) if windows_os? }
          )
        end

        prefix_command(lines.join("\n"))
      end
    end
  end
end

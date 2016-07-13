# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

require "kitchen/provisioner/chef_base"

module Kitchen

  module Provisioner

    # Chef Solo provisioner.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class ChefSolo < ChefBase

      kitchen_provisioner_api_version 2

      plugin_version Kitchen::VERSION

      default_config :solo_rb, {}

      default_config :chef_solo_path do |provisioner|
        provisioner.
          remote_path_join(%W[#{provisioner[:chef_omnibus_root]} bin chef-solo]).
          tap { |path| path.concat(".bat") if provisioner.windows_os? }
      end

      # (see Base#create_sandbox)
      def create_sandbox
        super
        prepare_solo_rb
      end

      def modern?
        version = config[:require_chef_omnibus]

        case version
        when nil, false, true, 11, "11", "latest"
          true
        else
          if Gem::Version.correct?(version)
            Gem::Version.new(version) >= Gem::Version.new("11.0") ? true : false
          else
            true
          end
        end
      end

      # (see Base#run_command)
      # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
      def run_command
        config[:log_level] = "info" if !modern? && config[:log_level] = "auto"
        cmd = sudo(config[:chef_solo_path]).dup.
          tap { |str| str.insert(0, "& ") if powershell_shell? }
        args = [
          "--config #{remote_path_join(config[:root_path], "solo.rb")}",
          "--log_level #{config[:log_level]}",
          "--no-color",
          "--json-attributes #{remote_path_join(config[:root_path], "dna.json")}"
        ]
        args << " --force-formatter" if modern?
        args << "--logfile #{config[:log_file]}" if config[:log_file]
        args << "--profile-ruby" if config[:profile_ruby]
        args << "--legacy-mode" if config[:legacy_mode]

        prefix_command(
          wrap_shell_code(
            [cmd, *args].join(" ").
            tap { |str| str.insert(0, reload_ps1_path) if windows_os? }
        )
      )
      end

      private

      # Writes a solo.rb configuration file to the sandbox directory.
      #
      # @api private
      def prepare_solo_rb
        data = default_config_rb.merge(config[:solo_rb])

        info("Preparing solo.rb")
        debug("Creating solo.rb from #{data.inspect}")

        File.open(File.join(sandbox_path, "solo.rb"), "wb") do |file|
          file.write(format_config_file(data))
        end
      end
    end
  end
end

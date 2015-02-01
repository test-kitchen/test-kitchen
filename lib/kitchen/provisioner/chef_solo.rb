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

      default_config :solo_rb, {}

      default_config :chef_solo_path do |provisioner|
        File.join(provisioner[:chef_omnibus_root], %w[bin chef-solo])
      end

      # (see Base#create_sandbox)
      def create_sandbox
        super
        prepare_solo_rb
      end

      # (see Base#run_command)
      def run_command
        cmd = sudo("#{chef_solo_path} #{run_command_args}")

        Util.wrap_command(cmd)
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

      # Returns a path string to the log file.
      #
      # @return [String] path string
      # @api private
      def log_file
        config[:log_file]
      end

      # Returns a log level symbol.
      #
      # @return [Symbol] log level symbol
      # @api private
      def log_level
        level = config[:log_level]

        level == :info ? :auto : level
      end

      # Returns a root path string.
      #
      # @return [String] root path string
      # @api private
      def root_path
        config[:root_path]
      end

      # Returns an arguments string for running Chef Solo.
      #
      # @return [String] arguments string
      # @api private
      def run_command_args
        args = [
          "--config #{root_path}/solo.rb",
          "--log_level #{log_level}",
          "--force-formatter",
          "--no-color",
          "--json-attributes #{root_path}/dna.json"
        ].join(" ")

        args << " --logfile #{log_file}" if log_file

        args
      end

      # Returns a path string for the Chef Solo binary.
      #
      # @return [String] path string
      # @api private
      def chef_solo_path
        config[:chef_solo_path]
      end
    end
  end
end

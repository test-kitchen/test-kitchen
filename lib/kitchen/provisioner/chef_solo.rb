#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

require_relative "chef_base"

module Kitchen
  module Provisioner
    # Chef Solo provisioner.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class ChefSolo < ChefBase
      kitchen_provisioner_api_version 2

      plugin_version Kitchen::VERSION

      # ChefSolo is dependent on Berkshelf, which is not thread-safe.
      # See discussion on https://github.com/test-kitchen/test-kitchen/issues/1307
      no_parallel_for :converge

      default_config :solo_rb, {}

      default_config :chef_solo_path do |provisioner|
        provisioner
          .remote_path_join(%W{#{provisioner[:chef_omnibus_root]} bin chef-solo})
          .tap { |path| path.concat(".bat") if provisioner.windows_os? }
      end

      # (see Base#config_filename)
      def config_filename
        "solo.rb"
      end

      # (see Base#create_sandbox)
      def create_sandbox
        super
        prepare_config_rb
      end

      # (see Base#run_command)
      def run_command
        cmd = sudo(config[:chef_solo_path]).dup
          .tap { |str| str.insert(0, "& ") if powershell_shell? }

        chef_cmd(cmd)
      end

      private

      # Returns an Array of command line arguments for the chef client.
      #
      # @return [Array<String>] an array of command line arguments
      # @api private
      def chef_args(solo_rb_filename)
        args = [
          "--config #{remote_path_join(config[:root_path], solo_rb_filename)}",
          "--log_level #{config[:log_level]}",
          "--force-formatter",
          "--no-color",
          "--json-attributes #{remote_path_join(config[:root_path], "dna.json")}",
        ]
        args << "--logfile #{config[:log_file]}" if config[:log_file]
        args << "--profile-ruby" if config[:profile_ruby]
        args << "--legacy-mode" if config[:legacy_mode]
        args
      end
    end
  end
end

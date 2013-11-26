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

require 'kitchen/provisioner/chef_base'

module Kitchen

  module Provisioner

    # Chef Solo provisioner.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class ChefSolo < ChefBase

      default_config :solo_rb, {}

      def create_sandbox
        create_chef_sandbox { prepare_solo_rb }
      end

      def run_command
        [
          sudo('chef-solo'),
          "--config #{config[:root_path]}/solo.rb",
          "--json-attributes #{config[:root_path]}/dna.json",
          config[:log_file] ? "--logfile #{config[:log_file]}" : nil,
          "--log_level #{config[:log_level]}"
        ].join(" ")
      end

      private

      def prepare_solo_rb
        data = default_config_rb.merge(config[:solo_rb])

        File.open(File.join(tmpdir, "solo.rb"), "wb") do |file|
          file.write(format_config_file(data))
        end
      end
    end
  end
end

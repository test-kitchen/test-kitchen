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

    # Chef Zero provisioner.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class ChefZero < ChefBase

      def create_sandbox
        create_chef_sandbox do
          prepare_chef_client_zero_rb
          prepare_client_rb
        end
      end

      def prepare_command
        ruby_bin = "/opt/chef/embedded/bin"

        <<-PREPARE.gsub(/^ {10}/, '')
          if [ ! -f "#{ruby_bin}/chef-zero" ] ; then
            echo "-----> Installing chef-zero and knife-essentials gems"
            #{sudo("#{ruby_bin}/gem")} install \
              chef-zero knife-essentials --no-ri --no-rdoc
          fi
        PREPARE
      end

      def run_command
        [
          sudo('/opt/chef/embedded/bin/ruby'),
          "#{home_path}/chef-client-zero.rb",
          "--config #{home_path}/client.rb",
          "--json-attributes #{home_path}/dna.json",
          "--log_level #{config[:log_level]}"
        ].join(" ")
      end

      def home_path
        "/tmp/kitchen-chef-zero".freeze
      end

      private

      def prepare_chef_client_zero_rb
        source = File.join(File.dirname(__FILE__),
          %w{.. .. .. support chef-client-zero.rb})
        FileUtils.cp(source, File.join(tmpdir, "chef-client-zero.rb"))
      end

      def prepare_client_rb
        client = []
        client << %{node_name "#{instance.name}"}
        client << %{file_cache_path "#{home_path}/cache"}
        client << %{cookbook_path "#{home_path}/cookbooks"}
        client << %{node_path "#{home_path}/nodes"}
        client << %{client_path "#{home_path}/clients"}
        client << %{role_path "#{home_path}/roles"}
        client << %{data_bag_path "#{home_path}/data_bags"}
        if instance.suite.encrypted_data_bag_secret_key_path
          secret = "#{home_path}/encrypted_data_bag_secret"
          client << %{encrypted_data_bag_secret "#{secret}"}
        end

        File.open(File.join(tmpdir, "client.rb"), "wb") do |file|
          file.write(client.join("\n"))
        end
      end
    end
  end
end

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

      def initialize(instance, config)
        super
        @ruby_binpath = config.fetch(:ruby_binpath, DEFAULT_RUBY_BINPATH)
      end

      def create_sandbox
        create_chef_sandbox do
          prepare_chef_client_zero_rb
          prepare_client_rb
        end
      end

      def prepare_command
        # use Bourne (/bin/sh) as Bash does not exist on all Unix flavors
        #
        # * we are installing latest chef in order to get chef-zero and
        #   Chef::ChefFS only. The version of Chef that gets run will be
        #   the installed omnibus package. Yep, this is funky :)
        <<-PREPARE.gsub(/^ {10}/, '')
          sh -c '
          #{sandbox_env(true)}
          if ! #{sudo(gem_bin)} list chef-zero -i >/dev/null; then
            echo "-----> Installing chef zero dependencies"
            #{sudo(gem_bin)} install chef --no-ri --no-rdoc --conservative
          fi'
        PREPARE
      end

      def run_command
        [
          "cd #{home_path};",
          sandbox_env,
          sudo(ruby_bin),
          "#{home_path}/chef-client-zero.rb",
          "--config #{home_path}/client.rb",
          "--json-attributes #{home_path}/dna.json",
          "--log_level #{config[:log_level]}"
        ].join(" ")
      end

      def home_path
        "/tmp/kitchen-chef-zero".freeze
      end

      def gem_bin
        @gem_bin ||= File.join(ruby_binpath, 'gem')
      end

      def ruby_bin
        @ruby_bin ||= File.join(ruby_binpath, 'ruby')
      end

      private

      DEFAULT_RUBY_BINPATH = "/opt/chef/embedded/bin".freeze

      attr_reader :ruby_binpath

      def sandbox_env(export=false)
        env = [
          "GEM_HOME=#{home_path}/gems",
          "GEM_PATH=$GEM_HOME",
          "GEM_CACHE=$GEM_HOME/cache",
          "PATH=$PATH:$GEM_HOME/bin",
          "KITCHEN_HOME_PATH=#{home_path}"
        ]

        if export
          env << "; export GEM_HOME GEM_PATH GEM_CACHE PATH;"
        end

        env.join(" ")
      end

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
        client << %{validation_key "#{home_path}/validation.pem"}
        client << %{client_key "#{home_path}/client.pem"}
        client << %{chef_server_url "http://127.0.0.1:8889"}
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

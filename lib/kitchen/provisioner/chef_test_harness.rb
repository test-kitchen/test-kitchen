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

    # Chef Test Harness provisioner.
    # - Heavily ripping off the ChefZero provider
    #
    # @author Scott Hain
    class ChefTestHarness < ChefBase

      default_config :client_rb, {}
      default_config :ruby_bindir, "/opt/chef/embedded/bin"
      default_config :json_attributes, true
      default_config :chef_git_url, "github.com/opscode/chef"
      default_config :chef_git_hash, "master"
      default_config :chef_zero_port, "8889"

      def create_sandbox
        super
        prepare_chef_in_test
        prepare_chef_client_zero_rb
        prepare_validation_pem
        prepare_client_rb
      end

      def prepare_command
        return if local_mode_supported?

        ruby_bin = config[:ruby_bindir]

        # use Bourne (/bin/sh) as Bash does not exist on all Unix flavors
        #
        # * we are installing latest chef in order to get chef-zero and
        #   Chef::ChefFS only. The version of Chef that gets run will be
        #   the installed omnibus package. Yep, this is funky :)
        <<-PREPARE.gsub(/^ {10}/, '')
          sh -c '
          #{chef_client_zero_env(:export)}
          if ! #{sudo("#{ruby_bin}/gem")} list chef-zero -i >/dev/null; then
            echo ">>>>>> Attempting to use chef-zero with old version of Chef"
            echo "-----> Installing chef zero dependencies"
            #{sudo("#{ruby_bin}/gem")} install chef --no-ri --no-rdoc --conservative
          fi'
        PREPARE
      end

      def run_command
        args = [
          "--config #{config[:root_path]}/client.rb",
          "--log_level #{config[:log_level]}"
        ]
        if config[:chef_zero_port]
          args <<  "--chef-zero-port #{config[:chef_zero_port]}"
        end
        if config[:json_attributes]
          args << "--json-attributes #{config[:root_path]}/dna.json"
        end

        if local_mode_supported?
          ["#{sudo('chef-client')} -z"].concat(args).join(" ")
        else
          [
            chef_client_zero_env,
            sudo("#{config[:ruby_bindir]}/ruby"),
            "#{config[:root_path]}/chef-client-zero.rb"
          ].concat(args).join(" ")
        end
      end

      def init_command
        prepare_chef_in_test
      end

      private

      def prepare_chef_in_test
        # in which we use hash as a delimiter for sed, because damn, slashes are annoying when you have that many.
        <<-GITDOWNLOAD.gsub(/^ {10}/, '')
          sh -c '
          echo "------ Downloading the specified Chef Client code from Github"
          #{sudo("wget")} -O /tmp/chef.tar.gz https://#{config[:chef_git_url]}/tarball/#{config[:chef_git_hash]}
          #{sudo("mkdir")} /opt/chef-test
          #{sudo("tar")} xf /tmp/chef.tar.gz -C /opt/chef-test/ --strip-components=1'
          echo "------ Doing a bundle install to set our dependencies up"
          export BUNDLE_GEMFILE=/opt/chef-test/Gemfile
          #{sudo("/opt/chef/embedded/bin/bundle")} install --gemfile=/opt/chef-test/Gemfile
          echo "------ Munging paths to piggyback on Omnibus Ruby Installation"
          #{sudo("sed")} -i 's#/usr/bin/env ruby#/opt/chef/embedded/bin ruby#g' /opt/chef-test/bin/chef-apply
          #{sudo("sed")} -i 's#/usr/bin/env ruby#/opt/chef/embedded/bin ruby#g' /opt/chef-test/bin/chef-client
          #{sudo("sed")} -i 's#/usr/bin/env ruby#/opt/chef/embedded/bin ruby#g' /opt/chef-test/bin/chef-shell
          #{sudo("sed")} -i 's#/usr/bin/env ruby#/opt/chef/embedded/bin ruby#g' /opt/chef-test/bin/chef-solo
          #{sudo("sed")} -i 's#/usr/bin/env ruby#/opt/chef/embedded/bin ruby#g' /opt/chef-test/bin/knife
          #{sudo("sed")} -i 's#/usr/bin/env ruby#/opt/chef/embedded/bin ruby#g' /opt/chef-test/bin/shef
          echo "------ Laying down stubs"

          echo "export BUNDLE_GEMFILE=/opt/chef-test/Gemfile; /opt/chef/embedded/bin/bundle exec /opt/chef/embedded/bin/ruby /opt/chef-test/bin/chef-apply \\$@" > /tmp/chef-apply_stub.sh
          #{sudo("chmod")} 755 /tmp/chef-apply_stub.sh
          #{sudo("chown")} root:root /tmp/chef-apply_stub.sh
          #{sudo("mv")} /tmp/chef-apply_stub.sh /opt/chef-test/bin/chef-apply_stub.sh

          echo "export BUNDLE_GEMFILE=/opt/chef-test/Gemfile; /opt/chef/embedded/bin/bundle exec /opt/chef/embedded/bin/ruby /opt/chef-test/bin/chef-client \\$@" > /tmp/chef-client_stub.sh
          #{sudo("chmod")} 755 /tmp/chef-client_stub.sh
          #{sudo("chown")} root:root /tmp/chef-client_stub.sh
          #{sudo("mv")} /tmp/chef-client_stub.sh /opt/chef-test/bin/chef-client_stub.sh

          echo "export BUNDLE_GEMFILE=/opt/chef-test/Gemfile; /opt/chef/embedded/bin/bundle exec /opt/chef/embedded/bin/ruby /opt/chef-test/bin/chef-shell \\$@" > /tmp/chef-shell_stub.sh
          #{sudo("chmod")} 755 /tmp/chef-shell_stub.sh
          #{sudo("chown")} root:root /tmp/chef-shell_stub.sh
          #{sudo("mv")} /tmp/chef-shell_stub.sh /opt/chef-test/bin/chef-shell_stub.sh

          echo "export BUNDLE_GEMFILE=/opt/chef-test/Gemfile; /opt/chef/embedded/bin/bundle exec /opt/chef/embedded/bin/ruby /opt/chef-test/bin/chef-solo \\$@" > /tmp/chef-solo_stub.sh
          #{sudo("chmod")} 755 /tmp/chef-solo_stub.sh
          #{sudo("chown")} root:root /tmp/chef-solo_stub.sh
          #{sudo("mv")} /tmp/chef-solo_stub.sh /opt/chef-test/bin/chef-solo_stub.sh

          echo "export BUNDLE_GEMFILE=/opt/chef-test/Gemfile; /opt/chef/embedded/bin/bundle exec /opt/chef/embedded/bin/ruby /opt/chef-test/bin/knife \\$@" > /tmp/knife_stub.sh
          #{sudo("chmod")} 755 /tmp/knife_stub.sh
          #{sudo("chown")} root:root /tmp/knife_stub.sh
          #{sudo("mv")} /tmp/knife_stub.sh /opt/chef-test/bin/knife_stub.sh

          echo "export BUNDLE_GEMFILE=/opt/chef-test/Gemfile; /opt/chef/embedded/bin/bundle exec /opt/chef/embedded/bin/ruby /opt/chef-test/bin/shef \\$@" > /tmp/shef_stub.sh
          #{sudo("chmod")} 755 /tmp/shef_stub.sh
          #{sudo("chown")} root:root /tmp/shef_stub.sh
          #{sudo("mv")} /tmp/shef_stub.sh /opt/chef-test/bin/shef_stub.sh

          echo "------ Linking to stubs to /usr/bin"
          #{sudo("ln -sf")} /opt/chef-test/bin/chef-client_stub.sh /usr/bin/chef-client
          #{sudo("ln -sf")} /opt/chef-test/bin/chef-apply_stub.sh /usr/bin/chef-apply
          #{sudo("ln -sf")} /opt/chef-test/bin/chef-shell_stub.sh /usr/bin/chef-shell
          #{sudo("ln -sf")} /opt/chef-test/bin/chef-solo_stub.sh /usr/bin/chef-solo
          #{sudo("ln -sf")} /opt/chef-test/bin/knife_stub.sh /usr/bin/knife
          #{sudo("ln -sf")} /opt/chef-test/bin/ohai_stub.sh /usr/bin/ohai
          #{sudo("ln -sf")} /opt/chef-test/bin/shef_stub.sh /usr/bin/shef
        GITDOWNLOAD
      end

      def prepare_chef_client_zero_rb
        return if local_mode_supported?

        source = File.join(File.dirname(__FILE__),
          %w{.. .. .. support chef-client-zero.rb})
        FileUtils.cp(source, File.join(sandbox_path, "chef-client-zero.rb"))
      end

      def prepare_validation_pem
        source = File.join(File.dirname(__FILE__),
          %w{.. .. .. support dummy-validation.pem})
        FileUtils.cp(source, File.join(sandbox_path, "validation.pem"))
      end

      def prepare_client_rb
        data = default_config_rb.merge(config[:client_rb])

        File.open(File.join(sandbox_path, "client.rb"), "wb") do |file|
          file.write(format_config_file(data))
        end
      end

      def chef_client_zero_env(extra = nil)
        args = [
          %{CHEF_REPO_PATH="#{config[:root_path]}"},
          %{GEM_HOME="#{config[:root_path]}/chef-client-zero-gems"},
          %{GEM_PATH="#{config[:root_path]}/chef-client-zero-gems"},
          %{GEM_CACHE="#{config[:root_path]}/chef-client-zero-gems/cache"}
        ]
        if extra == :export
          args << %{; export CHEF_REPO_PATH GEM_HOME GEM_PATH GEM_CACHE;}
        end
        args.join(" ")
      end

      # Determines whether or not local mode (a.k.a chef zero mode) is
      # supported in the version of Chef as determined by inspecting the
      # require_chef_omnibus config variable.
      #
      # The only way this method returns false is if require_chef_omnibus has
      # an explicit version set to less than 11.8.0, when chef zero mode was
      # introduced. Otherwise a modern Chef installation is assumed.
      def local_mode_supported?
        version = config[:require_chef_omnibus]

        case version
        when nil, false, true, "latest"
          true
        else
          Gem::Version.new(version) >= Gem::Version.new("11.8.0") ? true : false
        end
      end
    end
  end
end

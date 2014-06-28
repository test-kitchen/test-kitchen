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

require 'fileutils'
require 'pathname'
require 'json'

require 'kitchen/provisioner/chef/berkshelf'
require 'kitchen/provisioner/chef/librarian'
require 'kitchen/util'

module Kitchen

  module Provisioner

    # Common implementation details for Chef-related provisioners.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class ChefBase < Base

      default_config :require_chef_omnibus, true
      default_config :chef_omnibus_url, "https://www.getchef.com/chef/install.sh"
      default_config :run_list, []
      default_config :attributes, {}
      default_config :cookbook_files_glob, %w[README.* metadata.{json,rb}
        attributes/**/* definitions/**/* files/**/* libraries/**/*
        providers/**/* recipes/**/* resources/**/* templates/**/*].join(",")

      default_config :data_path do |provisioner|
        provisioner.calculate_path("data")
      end
      expand_path_for :data_path

      default_config :data_bags_path do |provisioner|
        provisioner.calculate_path("data_bags")
      end
      expand_path_for :data_bags_path

      default_config :environments_path do |provisioner|
        provisioner.calculate_path("environments")
      end
      expand_path_for :environments_path

      default_config :nodes_path do |provisioner|
        provisioner.calculate_path("nodes")
      end
      expand_path_for :nodes_path

      default_config :roles_path do |provisioner|
        provisioner.calculate_path("roles")
      end
      expand_path_for :roles_path

      default_config :clients_path do |provisioner|
        provisioner.calculate_path("clients")
      end
      expand_path_for :clients_path

      default_config :encrypted_data_bag_secret_key_path do |provisioner|
        provisioner.calculate_path("encrypted_data_bag_secret_key", :file)
      end
      expand_path_for :encrypted_data_bag_secret_key_path

      def install_command
        return unless config[:require_chef_omnibus]

        url = config[:chef_omnibus_url]
        flag = config[:require_chef_omnibus]
        version = if flag.is_a?(String) && flag != "latest"
          "-v #{flag.downcase}"
        else
          ""
        end

        # use Bourne (/bin/sh) as Bash does not exist on all Unix flavors
        install_string = create_chef_install_string(url, flag, version)

        # Check to see if we're pulling in a fresh new pre-release chef client for testing
        git_url = config[:chef_git_url]
        git_hash = config[:chef_git_hash]
        if((not git_url.nil?) && (not git_hash.nil?))
          install_string << create_chef_test_install_string(git_url, git_hash)
        end

        return "sh -c '#{install_string}'"
      end

      def init_command
        dirs = %w{cookbooks data data_bags environments roles clients}.
          map { |dir| File.join(config[:root_path], dir) }.join(" ")
        "#{sudo('rm')} -rf #{dirs} ; mkdir -p #{config[:root_path]}"
      end

      def create_sandbox
        super
        prepare_json
        prepare_cache
        prepare_cookbooks
        prepare_data
        prepare_data_bags
        prepare_environments
        prepare_nodes
        prepare_roles
        prepare_clients
        prepare_secret
      end

      protected

      def load_needed_dependencies!
        if File.exists?(berksfile)
          debug("Berksfile found at #{berksfile}, loading Berkshelf")
          Chef::Berkshelf.load!(logger)
        elsif File.exists?(cheffile)
          debug("Cheffile found at #{cheffile}, loading Librarian-Chef")
          Chef::Librarian.load!(logger)
        end
      end

      def format_config_file(data)
        data.each.map { |attr, value|
          [attr, (value.is_a?(Array) ? value.to_s : %{"#{value}"})].join(" ")
        }.join("\n")
      end

      def default_config_rb
        root = config[:root_path]

        {
          :node_name        => instance.name,
          :checksum_path    => "#{root}/checksums",
          :file_cache_path  => "#{root}/cache",
          :file_backup_path => "#{root}/backup",
          :cookbook_path    => ["#{root}/cookbooks", "#{root}/site-cookbooks"],
          :data_bag_path    => "#{root}/data_bags",
          :environment_path => "#{root}/environments",
          :node_path        => "#{root}/nodes",
          :role_path        => "#{root}/roles",
          :client_path      => "#{root}/clients",
          :user_path        => "#{root}/users",
          :validation_key   => "#{root}/validation.pem",
          :client_key       => "#{root}/client.pem",
          :chef_server_url  => "http://127.0.0.1:8889",
          :encrypted_data_bag_secret => "#{root}/encrypted_data_bag_secret",
        }
      end

      def prepare_json
        dna = config[:attributes].merge({ :run_list => config[:run_list] })

        File.open(File.join(sandbox_path, "dna.json"), "wb") do |file|
          file.write(dna.to_json)
        end
      end

      def prepare_data
        return unless data

        info("Preparing data")
        debug("Using data from #{data}")

        tmpdata_dir = File.join(sandbox_path, "data")
        FileUtils.mkdir_p(tmpdata_dir)
        FileUtils.cp_r(Dir.glob("#{data}/*"), tmpdata_dir)
      end

      def prepare_data_bags
        return unless data_bags

        info("Preparing data bags")
        debug("Using data bags from #{data_bags}")

        tmpbags_dir = File.join(sandbox_path, "data_bags")
        FileUtils.mkdir_p(tmpbags_dir)
        FileUtils.cp_r(Dir.glob("#{data_bags}/*"), tmpbags_dir)
      end

      def prepare_roles
        return unless roles

        info("Preparing roles")
        debug("Using roles from #{roles}")

        tmproles_dir = File.join(sandbox_path, "roles")
        FileUtils.mkdir_p(tmproles_dir)
        FileUtils.cp_r(Dir.glob("#{roles}/*"), tmproles_dir)
      end

      def prepare_clients
        return unless clients

        info("Preparing clients")
        debug("Using roles from #{clients}")

        tmpclients_dir = File.join(sandbox_path, "clients")
        FileUtils.mkdir_p(tmpclients_dir)
        FileUtils.cp_r(Dir.glob("#{clients}/*"), tmpclients_dir)
      end

      def prepare_nodes
        return unless nodes

        info("Preparing nodes")
        debug("Using nodes from #{nodes}")

        tmpnodes_dir = File.join(sandbox_path, "nodes")
        FileUtils.mkdir_p(tmpnodes_dir)
        FileUtils.cp_r(Dir.glob("#{nodes}/*"), tmpnodes_dir)
      end

      def prepare_environments
        return unless environments

        info("Preparing environments")
        debug("Using environments from #{environments}")

        tmpenvs_dir = File.join(sandbox_path, "environments")
        FileUtils.mkdir_p(tmpenvs_dir)
        FileUtils.cp_r(Dir.glob("#{environments}/*"), tmpenvs_dir)
      end

      def prepare_secret
        return unless secret

        info("Preparing encrypted data bag secret")
        debug("Using secret from #{secret}")

        FileUtils.cp_r(secret, File.join(sandbox_path, "encrypted_data_bag_secret"))
      end

      def prepare_cache
        FileUtils.mkdir_p(File.join(sandbox_path, "cache"))
      end

      def prepare_cookbooks
        if File.exists?(berksfile)
          resolve_with_berkshelf
        elsif File.exists?(cheffile)
          resolve_with_librarian
        elsif File.directory?(cookbooks_dir)
          cp_cookbooks
        elsif File.exists?(metadata_rb)
          cp_this_cookbook
        else
          make_fake_cookbook
        end

        filter_only_cookbook_files
      end

      def filter_only_cookbook_files
        info("Removing non-cookbook files before transfer")
        FileUtils.rm(all_files_in_cookbooks - only_cookbook_files)
      end

      def all_files_in_cookbooks
        Dir.glob(File.join(tmpbooks_dir, "**/*"), File::FNM_DOTMATCH).
          select { |fn| File.file?(fn) && ! %w{. ..}.include?(fn) }
      end

      def only_cookbook_files
        glob = File.join(tmpbooks_dir, "*", "{#{config[:cookbook_files_glob]}}")

        Dir.glob(glob, File::FNM_DOTMATCH).
          select { |fn| File.file?(fn) && ! %w{. ..}.include?(fn) }
      end

      def berksfile
        File.join(config[:kitchen_root], "Berksfile")
      end

      def cheffile
        File.join(config[:kitchen_root], "Cheffile")
      end

      def metadata_rb
        File.join(config[:kitchen_root], "metadata.rb")
      end

      def cookbooks_dir
        File.join(config[:kitchen_root], "cookbooks")
      end

      def site_cookbooks_dir
        File.join(config[:kitchen_root], "site-cookbooks")
      end

      def data_bags
        config[:data_bags_path]
      end

      def roles
        config[:roles_path]
      end

      def clients
        config[:clients_path]
      end

      def nodes
        config[:nodes_path]
      end

      def data
        config[:data_path]
      end

      def environments
        config[:environments_path]
      end

      def secret
        config[:encrypted_data_bag_secret_key_path]
      end

      def tmpbooks_dir
        File.join(sandbox_path, "cookbooks")
      end

      def tmpsitebooks_dir
        File.join(sandbox_path, "cookbooks")
      end

      def cp_cookbooks
        info("Preparing cookbooks from project directory")
        debug("Using cookbooks from #{cookbooks_dir}")

        FileUtils.mkdir_p(tmpbooks_dir)
        FileUtils.cp_r(File.join(cookbooks_dir, "."), tmpbooks_dir)

        cp_site_cookbooks if File.directory?(site_cookbooks_dir)
        cp_this_cookbook if File.exists?(metadata_rb)
      end

      def cp_site_cookbooks
        info("Preparing site-cookbooks from project directory")
        debug("Using cookbooks from #{site_cookbooks_dir}")

        FileUtils.mkdir_p(tmpsitebooks_dir)
        FileUtils.cp_r(File.join(site_cookbooks_dir, "."), tmpsitebooks_dir)
      end

      def cp_this_cookbook
        info("Preparing current project directory as a cookbook")
        debug("Using metadata.rb from #{metadata_rb}")

        cb_name = MetadataChopper.extract(metadata_rb).first or raise(UserError,
          "The metadata.rb does not define the 'name' key." +
            " Please add: `name '<cookbook_name>'` to metadata.rb and retry")

        cb_path = File.join(tmpbooks_dir, cb_name)

        glob = Dir.glob("#{config[:kitchen_root]}/**")

        FileUtils.mkdir_p(cb_path)
        FileUtils.cp_r(glob, cb_path)
      end

      def make_fake_cookbook
        info("Berksfile, Cheffile, cookbooks/, or metadata.rb not found " +
          "so Chef will run with effectively no cookbooks. Is this intended?")
        name = File.basename(config[:kitchen_root])
        fake_cb = File.join(tmpbooks_dir, name)
        FileUtils.mkdir_p(fake_cb)
        File.open(File.join(fake_cb, "metadata.rb"), "wb") do |file|
          file.write(%{name "#{name}\n"})
        end
      end

      def resolve_with_berkshelf
        Kitchen.mutex.synchronize do
          Chef::Berkshelf.new(berksfile, tmpbooks_dir, logger).resolve
        end
      end

      def resolve_with_librarian
        Kitchen.mutex.synchronize do
          Chef::Librarian.new(cheffile, tmpbooks_dir, logger).resolve
        end
      end

      def create_chef_install_string(url, flag, version)
        <<-INSTALL.gsub(/^ {10}/, '')
          #{Util.shell_helpers}

          should_update_chef() {
            case "#{flag}" in
              true|`chef-solo -v | cut -d " " -f 2`) return 1 ;;
              latest|*) return 0 ;;
            esac
          }

          if [ ! -d "/opt/chef" ] || should_update_chef ; then
            echo "-----> Installing Chef Omnibus (#{flag})"
            do_download #{url} /tmp/install.sh
            #{sudo('sh')} /tmp/install.sh #{version}
          fi
        INSTALL
      end

      def create_chef_test_install_string(git_url, git_hash)
        <<-INSTALLTEST.gsub(/^ {10}/, '')
          if [ ! -d /opt/chef-test ]; then
            echo "------ Downloading the specified Chef Client code from Github"
            do_download https://#{git_url}/tarball/#{git_hash} /tmp/chef.tar.gz
            #{sudo("mkdir")} /opt/chef-test
            #{sudo("tar")} xf /tmp/chef.tar.gz -C /opt/chef-test/ --strip-components=1
          fi

          echo "------ Installing gcc so we can build native gems"
          if [ -f /etc/redhat-release -o -f /etc/fedora-release -o -f /etc/system-release ]; then
            #{sudo("yum")} install -y gcc
          elif [ -f /etc/debian_version ]; then 
            #{sudo("apt-get")} install -y gcc
          else 
            echo "Platform not supported, sorry for the inconvenience."
          fi

          echo "------ Doing a bundle install to set our dependencies up"
          export BUNDLE_GEMFILE=/opt/chef-test/Gemfile
          #{sudo("/opt/chef/embedded/bin/bundle")} install --gemfile=/opt/chef-test/Gemfile
          cd /opt/chef-test
          echo "------ Building our chef test gem"
          #{sudo("/opt/chef/embedded/bin/gem")} build /opt/chef-test/chef.gemspec
          echo "------ Installing test version of chef"
          #{sudo("/opt/chef/embedded/bin/gem")} install /opt/chef-test/chef --no-ri --no-rdoc
        INSTALLTEST
      end
    end
  end
end

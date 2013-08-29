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
require 'json'

module Kitchen

  module Provisioner

    # Common implementation details for Chef-related provisioners.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class ChefBase < Base

      def install_command
        return nil unless config[:require_chef_omnibus]

        url = config[:chef_omnibus_url] || "https://www.opscode.com/chef/install.sh"
        flag = config[:require_chef_omnibus]
        version = if flag.is_a?(String) && flag != "latest"
          "-s -- -v #{flag.downcase}"
        else
          ""
        end

        <<-INSTALL.gsub(/^ {10}/, '')
          bash -c '
          should_update_chef() {
            case "#{flag}" in
              true|$(chef-solo -v | cut -d " " -f 2)) return 1 ;;
              latest|*) return 0 ;;
            esac
          }

          if [ ! -d "/opt/chef" ] || should_update_chef ; then
            PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
            export PATH
            echo "-----> Installing Chef Omnibus (#{flag})"
            if command -v wget >/dev/null ; then
              wget #{url} -O - | #{sudo('bash')} #{version}
            elif command -v curl >/dev/null ; then
              curl -sSL #{url} | #{sudo('bash')} #{version}
            else
              echo ">>>>>> Neither wget nor curl found on this instance."
              exit 16
            fi
          fi'
        INSTALL
      end

      def init_command
        "#{sudo('rm')} -rf #{home_path}"
      end

      def cleanup_sandbox
        return if tmpdir.nil?

        debug("Cleaning up local sandbox in #{tmpdir}")
        FileUtils.rmtree(tmpdir)
      end

      protected

      def create_chef_sandbox
        @tmpdir = Dir.mktmpdir("#{instance.name}-sandbox-")
        debug("Creating local sandbox in #{tmpdir}")

        yield if block_given?
        prepare_json
        prepare_data_bags
        prepare_roles
        prepare_nodes
        prepare_secret
        prepare_cache
        prepare_cookbooks
        tmpdir
      end

      def prepare_json
        File.open(File.join(tmpdir, "dna.json"), "wb") do |file|
          file.write(instance.dna.to_json)
        end
      end

      def prepare_data_bags
        return unless data_bags

        info("Preparing data bags")
        debug("Using data bags from #{data_bags}")

        tmpbags_dir = File.join(tmpdir, "data_bags")
        FileUtils.mkdir_p(tmpbags_dir)
        FileUtils.cp_r(Dir.glob("#{data_bags}/*"), tmpbags_dir)
      end

      def prepare_roles
        return unless roles

        info("Preparing roles")
        debug("Using roles from #{roles}")

        tmproles_dir = File.join(tmpdir, "roles")
        FileUtils.mkdir_p(tmproles_dir)
        FileUtils.cp_r(Dir.glob("#{roles}/*"), tmproles_dir)
      end

      def prepare_nodes
        return unless nodes

        info("Preparing nodes")
        debug("Using nodes from #{nodes}")

        tmpnodes_dir = File.join(tmpdir, "nodes")
        FileUtils.mkdir_p(tmpnodes_dir)
        FileUtils.cp_r(Dir.glob("#{nodes}/*"), tmpnodes_dir)
      end

      def prepare_secret
        return unless secret

        info("Preparing encrypted data bag secret")
        debug("Using secret from #{secret}")

        FileUtils.cp_r(secret, File.join(tmpdir, "encrypted_data_bag_secret"))
      end

      def prepare_cache
        FileUtils.mkdir_p(File.join(tmpdir, "cache"))
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
          FileUtils.rmtree(tmpdir)
          fatal("Berksfile, Cheffile, cookbooks/, or metadata.rb" +
            " must exist in #{kitchen_root}")
          raise UserError, "Cookbooks could not be found"
        end

        filter_only_cookbook_files
      end

      def filter_only_cookbook_files
        info("Removing non-cookbook files in sandbox")

        all_files = Dir.glob(File.join(tmpbooks_dir, "**/*")).
          select { |fn| File.file?(fn) }
        cookbook_files = Dir.glob(File.join(tmpbooks_dir, cookbook_files_glob)).
          select { |fn| File.file?(fn) }

        FileUtils.rm(all_files - cookbook_files)
      end

      def cookbook_files_glob
        files = %w{README.* metadata.{json,rb}
          attributes/**/* definitions/**/* files/**/* libraries/**/*
          providers/**/* recipes/**/* resources/**/* templates/**/*
        }

        "*/{#{files.join(',')}}"
      end

      def berksfile
        File.join(kitchen_root, "Berksfile")
      end

      def cheffile
        File.join(kitchen_root, "Cheffile")
      end

      def metadata_rb
        File.join(kitchen_root, "metadata.rb")
      end

      def cookbooks_dir
        File.join(kitchen_root, "cookbooks")
      end

      def data_bags
        instance.suite.data_bags_path
      end

      def roles
        instance.suite.roles_path
      end

      def nodes
        instance.suite.nodes_path
      end

      def secret
        instance.suite.encrypted_data_bag_secret_key_path
      end

      def tmpbooks_dir
        File.join(tmpdir, "cookbooks")
      end

      def cp_cookbooks
        info("Preparing cookbooks from project directory")
        debug("Using cookbooks from #{cookbooks_dir}")

        FileUtils.mkdir_p(tmpbooks_dir)
        FileUtils.cp_r(File.join(cookbooks_dir, "."), tmpbooks_dir)
        cp_this_cookbook if File.exists?(metadata_rb)
      end

      def cp_this_cookbook
        info("Preparing current project directory as a cookbook")
        debug("Using metadata.rb from #{metadata_rb}")

        cb_name = MetadataChopper.extract(metadata_rb).first or raise(UserError,
          "The metadata.rb does not define the 'name' key." +
            " Please add: `name '<cookbook_name>'` to metadata.rb and retry")

        cb_path = File.join(tmpbooks_dir, cb_name)
        glob = Dir.glob("#{kitchen_root}/{metadata.rb,README.*,definitions," +
          "attributes,files,libraries,providers,recipes,resources,templates}")

        FileUtils.mkdir_p(cb_path)
        FileUtils.cp_r(glob, cb_path)
      end

      def resolve_with_berkshelf
        info("Resolving cookbook dependencies with Berkshelf")
        debug("Using Berksfile from #{berksfile}")

        begin
          require 'berkshelf'
        rescue LoadError
          fatal("The `berkself' gem is missing and must be installed." +
            " Run `gem install berkshelf` or add the following " +
            "to your Gemfile if you are using Bundler: `gem 'berkshelf'`.")
          raise UserError, "Could not load Berkshelf"
        end

        Kitchen.mutex.synchronize do
          Berkshelf::Berksfile.from_file(berksfile).
            install(:path => tmpbooks_dir)
        end
      end

      def resolve_with_librarian
        info("Resolving cookbook dependencies with Librarian-Chef")
        debug("Using Cheffile from #{cheffile}")

        begin
          require 'librarian/chef/environment'
          require 'librarian/action/resolve'
          require 'librarian/action/install'
        rescue LoadError
          fatal("The `librarian-chef' gem is missing and must be installed." +
            " Run `gem install librarian-chef` or add the following " +
            "to your Gemfile if you are using Bundler: `gem 'librarian-chef'`.")
          raise UserError, "Could not load Librarian-Chef"
        end

        Kitchen.mutex.synchronize do
          env = Librarian::Chef::Environment.new(:project_path => kitchen_root)
          env.config_db.local["path"] = tmpbooks_dir
          Librarian::Action::Resolve.new(env).run
          Librarian::Action::Install.new(env).run
        end
      end
    end
  end
end

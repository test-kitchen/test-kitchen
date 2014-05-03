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
      default_config :log_file, nil
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
        provisioner.calculate_path("encrypted_data_bag_secret_key", :type => :file)
      end
      expand_path_for :encrypted_data_bag_secret_key_path

      # (see Base#install_command)
      def install_command
        return unless config[:require_chef_omnibus]

        lines = [Util.shell_helpers, chef_shell_helpers, chef_install_function]
        Util.wrap_command(lines.join("\n"))
      end

      # (see Base#init_command)
      def init_command
        dirs = %w{cookbooks data data_bags environments roles clients}.
          map { |dir| File.join(config[:root_path], dir) }.join(" ")
        lines = ["#{sudo('rm')} -rf #{dirs}", "mkdir -p #{config[:root_path]}"]

        Util.wrap_command(lines.join("\n"))
      end

      # (see Base#create_sandbox)
      def create_sandbox
        super
        prepare_json
        prepare_cache
        prepare_cookbooks
        prepare(:data)
        prepare(:data_bags)
        prepare(:environments)
        prepare(:nodes)
        prepare(:roles)
        prepare(:clients)
        prepare(
          :secret,
          :type => :file,
          :dest_name => "encrypted_data_bag_secret",
          :key_name => :encrypted_data_bag_secret_key_path
        )
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

      def chef_shell_helpers
        IO.read(File.join(
          File.dirname(__FILE__), %w{.. .. .. support chef_helpers.sh}
        ))
      end

      def chef_install_function
        version = config[:require_chef_omnibus].to_s.downcase
        pretty_version = case version
        when "true" then "install only if missing"
        when "latest" then "always install latest version"
        else version
        end
        install_flags = %w{latest true}.include?(version) ? "" : "-v #{version}"

        <<-INSTALL.gsub(/^ {10}/, '')
          if should_update_chef "/opt/chef" "#{version}" ; then
            echo "-----> Installing Chef Omnibus (#{pretty_version})"
            do_download #{config[:chef_omnibus_url]} /tmp/install.sh
            #{sudo('sh')} /tmp/install.sh #{install_flags}
          else
            echo "-----> Chef Omnibus installation detected (#{pretty_version})"
          fi
        INSTALL
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
          :encrypted_data_bag_secret => "#{root}/encrypted_data_bag_secret"
        }
      end

      # Prepares a generic Chef component source directory or file for
      # inclusion in the sandbox path. These components might includes nodes,
      # roles, etc.
      #
      # @param component [Symbol,String] a component name such as `:node`
      # @param opts [Hash] optional configuration
      # @option opts [Symbol] :type whether the component is a directory or
      #   file (default: `:directory`)
      # @option opts [Symbol] :key_name the key name in the config hash from
      #   which to pull the source path (default: `"#{component}_path"`)
      # @option opts [String] :dest_name the destination file or directory
      #   basename in the sandbox path (default: `component.to_s`)
      # @api private
      def prepare(component, opts = {})
        opts = { :type => :directory }.merge(opts)
        key_name = opts.fetch(:key_name, "#{component.to_s}_path")
        src = config[key_name.to_sym]
        return if src.nil?

        info("Preparing #{component}")
        debug("Using #{component} from #{src}")

        dest = File.join(sandbox_path, opts.fetch(:dest_name, component.to_s))

        case opts[:type]
        when :directory
          FileUtils.mkdir_p(dest)
          FileUtils.cp_r(Dir.glob("#{src}/*"), dest)
        when :file
          FileUtils.mkdir_p(File.dirname(dest))
          FileUtils.cp_r(src, dest)
        end
      end

      def prepare_json
        dna = config[:attributes].merge(:run_list => config[:run_list])

        info("Preparing dna.json")
        debug("Creating dna.json from #{dna.inspect}")

        File.open(File.join(sandbox_path, "dna.json"), "wb") do |file|
          file.write(dna.to_json)
        end
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
          file.write(%{name "#{name}"\n})
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
    end
  end
end

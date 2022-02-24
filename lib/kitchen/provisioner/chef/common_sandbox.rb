#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2015, Fletcher Nichol
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

require "json" unless defined?(JSON)

module Kitchen
  module Provisioner
    module Chef
      # Internal object to manage common sandbox preparation for
      # Chef-related provisioners.
      #
      # @author Fletcher Nichol <fnichol@nichol.ca>
      # @api private
      class CommonSandbox
        include Logging

        # Constructs a new object, taking config, a sandbox path, and an
        # instance.
        #
        # @param config [Hash] configuration hash
        # @param sandbox_path [String] path to local sandbox directory
        # @param instance [Instance] an instance
        def initialize(config, sandbox_path, instance)
          @config = config
          @sandbox_path = sandbox_path
          @instance = instance
        end

        # Populate the sandbox.
        def populate
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
            type: :file,
            dest_name: "encrypted_data_bag_secret",
            key_name: :encrypted_data_bag_secret_key_path
          )
        end

        private

        # @return [Hash] configuration hash
        # @api private
        attr_reader :config

        # @return [Instance] an instance
        # @api private
        attr_reader :instance

        # @return [String] path to local sandbox directory
        # @api private
        attr_reader :sandbox_path

        # @return [String] name of the policy_group, nil results in "local"
        # @api private
        attr_reader :policy_group

        # Generates a list of all files in the cookbooks directory in the
        # sandbox path.
        #
        # @return [Array<String>] an array of absolute paths to files
        # @api private
        def all_files_in_cookbooks
          Util.list_directory(tmpbooks_dir, include_dot: true, recurse: true)
            .select { |fn| File.file?(fn) }
        end

        # @return [String] an absolute path to a Policyfile, relative to the
        #   kitchen root
        # @api private
        def policyfile
          basename = config[:policyfile_path] || config[:policyfile] || "Policyfile.rb"
          File.expand_path(basename, config[:kitchen_root])
        end

        # @return [String] an absolute path to a Berksfile, relative to the
        #   kitchen root
        # @api private
        def berksfile
          basename = config[:berksfile_path] || "Berksfile"
          File.expand_path(basename, config[:kitchen_root])
        end

        # @return [String] an absolute path to a cookbooks/ directory, relative
        #   to the kitchen root
        # @api private
        def cookbooks_dir
          File.join(config[:kitchen_root], "cookbooks")
        end

        # Copies a cookbooks/ directory into the sandbox path.
        #
        # @api private
        def cp_cookbooks
          info("Preparing cookbooks from project directory")
          debug("Using cookbooks from #{cookbooks_dir}")

          FileUtils.mkdir_p(tmpbooks_dir)
          FileUtils.cp_r(File.join(cookbooks_dir, "."), tmpbooks_dir)

          cp_site_cookbooks if File.directory?(site_cookbooks_dir)
          cp_this_cookbook if File.exist?(metadata_rb)
        end

        # Copies a site-cookbooks/ directory into the sandbox path.
        #
        # @api private
        def cp_site_cookbooks
          info("Preparing site-cookbooks from project directory")
          debug("Using cookbooks from #{site_cookbooks_dir}")

          FileUtils.mkdir_p(tmpsitebooks_dir)
          FileUtils.cp_r(File.join(site_cookbooks_dir, "."), tmpsitebooks_dir)
        end

        # Copies the current project, assumed to be a Chef cookbook into the
        # sandbox path.
        #
        # @api private
        def cp_this_cookbook
          info("Preparing current project directory as a cookbook")
          debug("Using metadata.rb from #{metadata_rb}")

          cb_name = MetadataChopper.extract(metadata_rb).first || raise(UserError,
            "The metadata.rb does not define the 'name' key." \
              " Please add: `name '<cookbook_name>'` to metadata.rb and retry")

          cb_path = File.join(tmpbooks_dir, cb_name)

          glob = Util.list_directory(config[:kitchen_root])

          FileUtils.mkdir_p(cb_path)
          FileUtils.cp_r(glob, cb_path)
        end

        # Removes all non-cookbook files in the sandbox path.
        #
        # @api private
        def filter_only_cookbook_files
          info("Removing non-cookbook files before transfer")
          FileUtils.rm(all_files_in_cookbooks - only_cookbook_files)
          Util.list_directory(tmpbooks_dir, recurse: true)
            .reverse_each { |fn| FileUtils.rmdir(fn) if File.directory?(fn) && Dir.entries(fn).size == 2 }
        end

        # @return [Logger] the instance's logger or Test Kitchen's common
        #   logger otherwise
        # @api private
        def logger
          instance ? instance.logger : Kitchen.logger
        end

        # Creates a minimal, no-op cookbook in the sandbox path.
        #
        # @api private
        def make_fake_cookbook
          info("Policyfile, Berksfile, cookbooks/, or metadata.rb not found " \
            "so Chef Infra Client will run, but do nothing. Is this intended?")
          name = File.basename(config[:kitchen_root])
          fake_cb = File.join(tmpbooks_dir, name)
          FileUtils.mkdir_p(fake_cb)
          File.open(File.join(fake_cb, "metadata.rb"), "wb") do |file|
            file.write(%{name "#{name}"\n})
          end
        end

        # @return [String] an absolute path to a metadata.rb, relative to the
        #   kitchen root
        # @api private
        def metadata_rb
          File.join(config[:kitchen_root], "metadata.rb")
        end

        # Generates a list of all typical cookbook files needed in a Chef run,
        # located in the cookbooks directory in the sandbox path.
        #
        # @return [Array<String>] an array of absolute paths to files
        # @api private
        def only_cookbook_files
          glob = File.join("*", "{#{config[:cookbook_files_glob]}}")
          Util.safe_glob(tmpbooks_dir, glob, File::FNM_DOTMATCH)
            .select { |fn| File.file?(fn) && ! %w{. ..}.include?(fn) }
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
          opts = { type: :directory }.merge(opts)
          key_name = opts.fetch(:key_name, "#{component}_path")
          src = config[key_name.to_sym]
          return if src.nil?

          info("Preparing #{component}")
          debug("Using #{component} from #{src}")

          dest = File.join(sandbox_path, opts.fetch(:dest_name, component.to_s))

          case opts[:type]
          when :directory
            FileUtils.mkdir_p(dest)
            Array(src).each { |dir| FileUtils.cp_r(Util.list_directory(dir), dest) }
          when :file
            FileUtils.mkdir_p(File.dirname(dest))
            Array(src).each { |file| FileUtils.cp_r(file, dest) }
          end
        end

        # Prepares a cache directory for inclusion in the sandbox path.
        #
        # @api private
        def prepare_cache
          FileUtils.mkdir_p(File.join(sandbox_path, "cache"))
        end

        # Prepares Chef cookbooks for inclusion in the sandbox path.
        #
        # @api private
        # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        def prepare_cookbooks
          if File.exist?(policyfile)
            resolve_with_policyfile
          elsif File.exist?(berksfile)
            resolve_with_berkshelf
          elsif File.directory?(cookbooks_dir)
            cp_cookbooks
          elsif File.exist?(metadata_rb)
            cp_this_cookbook
          else
            make_fake_cookbook
          end

          filter_only_cookbook_files
        end

        # Prepares a Chef JSON file, sometimes called a dna.json or
        # first-boot.json, for inclusion in the sandbox path.
        #
        # @api private
        def prepare_json
          dna = if File.exist?(policyfile)
                  update_dna_for_policyfile
                else
                  config[:attributes].merge(run_list: config[:run_list])
                end

          info("Preparing dna.json")
          debug("Creating dna.json from #{dna.inspect}")

          File.open(File.join(sandbox_path, "dna.json"), "wb") do |file|
            file.write(dna.to_json)
          end
        end

        def update_dna_for_policyfile
          policy = Chef::Policyfile.new(
            policyfile, sandbox_path,
            logger: logger,
            always_update: config[:always_update_cookbooks],
            policy_group: policy_group,
            license: config[:chef_license]
          )
          Kitchen.mutex.synchronize do
            policy.compile
          end
          policy_name = JSON.parse(IO.read(policy.lockfile))["name"]
          policy_group = config[:policy_group] || "local"
          config[:attributes].merge(policy_name: policy_name, policy_group: policy_group)
        end

        # Performs a Policyfile cookbook resolution inside a common mutex.
        #
        # @api private
        def resolve_with_policyfile
          Kitchen.mutex.synchronize do
            Chef::Policyfile.new(
              policyfile, sandbox_path,
              logger: logger,
              always_update: config[:always_update_cookbooks],
              policy_group: config[:policy_group],
              license: config[:chef_license]
            ).resolve
          end
        end

        # Performs a Berkshelf cookbook resolution inside a common mutex.
        #
        # @api private
        def resolve_with_berkshelf
          Kitchen.mutex.synchronize do
            Chef::Berkshelf.new(berksfile, tmpbooks_dir,
              logger: logger,
              always_update: config[:always_update_cookbooks]).resolve
          end
        end

        # @return [String] an absolute path to a site-cookbooks/ directory,
        #   relative to the kitchen root
        # @api private
        def site_cookbooks_dir
          File.join(config[:kitchen_root], "site-cookbooks")
        end

        # @return [String] an absolute path to a cookbooks/ directory in the
        #   sandbox path
        # @api private
        def tmpbooks_dir
          File.join(sandbox_path, "cookbooks")
        end

        # @return [String] an absolute path to a site cookbooks directory in the
        #   sandbox path
        # @api private
        def tmpsitebooks_dir
          File.join(sandbox_path, "cookbooks")
        end
      end
    end
  end
end

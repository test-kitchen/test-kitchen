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

require "fileutils"
require "pathname"
require "json"
require "cgi"

require "kitchen/provisioner/chef/policyfile"
require "kitchen/provisioner/chef/berkshelf"
require "kitchen/provisioner/chef/common_sandbox"
require "kitchen/util"
require "mixlib/install"
require "mixlib/install/script_generator"
require "license_acceptance/acceptor"

begin
  require "chef-config/config"
  require "chef-config/workstation_config_loader"
rescue LoadError # rubocop:disable Lint/HandleExceptions
  # This space left intentionally blank.
end

module Kitchen
  module Provisioner
    # Common implementation details for Chef-related provisioners.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class ChefBase < Base
      default_config :require_chef_omnibus, true
      default_config :chef_omnibus_url, "https://omnitruck.chef.io/install.sh"
      default_config :chef_omnibus_install_options, nil
      default_config :chef_license, nil
      default_config :run_list, []
      default_config :attributes, {}
      default_config :config_path, nil
      default_config :log_file, nil
      default_config :log_level do |provisioner|
        provisioner[:debug] ? "debug" : "auto"
      end
      default_config :profile_ruby, false
      # The older policyfile_zero used `policyfile` so support it for compat.
      default_config :policyfile, nil
      # Will try to autodetect by searching for `Policyfile.rb` if not set.
      # If set, will error if the file doesn't exist.
      default_config :policyfile_path, nil
      # If set to true (which is the default from `chef generate`), try to update
      # backend cookbook downloader on every kitchen run.
      default_config :always_update_cookbooks, false
      default_config :cookbook_files_glob, %w(
        README.* VERSION metadata.{json,rb} attributes.rb recipe.rb
        attributes/**/* definitions/**/* files/**/* libraries/**/*
        providers/**/* recipes/**/* resources/**/* templates/**/*
      ).join(",")
      # to ease upgrades, allow the user to turn deprecation warnings into errors
      default_config :deprecations_as_errors, false

      # Override the default from Base so reboot handling works by default for Chef.
      default_config :retry_on_exit_code, [35, 213]

      default_config :multiple_converge, 1

      default_config :enforce_idempotency, false

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
        provisioner.calculate_path("encrypted_data_bag_secret_key", type: :file)
      end
      expand_path_for :encrypted_data_bag_secret_key_path

      #
      # New configuration options per RFC 091
      # https://github.com/chef/chef-rfc/blob/master/rfc091-deprecate-kitchen-settings.md
      #

      # Setting product_name to nil. It is currently the pivot point
      # between the two install paths (Mixlib::Install::ScriptGenerator and Mixlib::Install)
      default_config :product_name

      default_config :product_version, :latest

      default_config :channel, :stable

      default_config :install_strategy, "once"

      default_config :platform

      default_config :platform_version

      default_config :architecture

      default_config :download_url

      default_config :checksum

      deprecate_config_for :require_chef_omnibus do |provisioner|
        case
        when provisioner[:require_chef_omnibus] == false
          Util.outdent!(<<-MSG)
            The 'require_chef_omnibus' attribute with value of 'false' will
            change to use the new 'install_strategy' attribute with a value of 'skip'.

            Note: 'product_name' must be set in order to use 'install_strategy'.
            Although this seems counterintuitive, it is necessary until
            'product_name' replaces 'require_chef_omnibus' as the default.

            # New Usage #
            provisioner:
              product_name: <chef or chefdk>
              install_strategy: skip
          MSG
        when provisioner[:require_chef_omnibus].to_s.match(/\d/)
          Util.outdent!(<<-MSG)
            The 'require_chef_omnibus' attribute with version values will change
            to use the new 'product_version' attribute.

            Note: 'product_name' must be set in order to use 'product_version'
            until 'product_name' replaces 'require_chef_omnibus' as the default.

            # New Usage #
            provisioner:
              product_name: <chef or chefdk>
              product_version: #{provisioner[:require_chef_omnibus]}
          MSG
        when provisioner[:require_chef_omnibus] == "latest"
          Util.outdent!(<<-MSG)
            The 'require_chef_omnibus' attribute with value of 'latest' will change
            to use the new 'install_strategy' attribute with a value of 'always'.

            Note: 'product_name' must be set in order to use 'install_strategy'
            until 'product_name' replaces 'require_chef_omnibus' as the default.

            # New Usage #
            provisioner:
              product_name: <chef or chefdk>
              install_strategy: always
          MSG
        end
      end

      deprecate_config_for :chef_omnibus_url, Util.outdent!(<<-MSG)
        Changing the 'chef_omnibus_url' attribute breaks existing functionality. It will
        be removed in a future version.
      MSG

      deprecate_config_for :chef_omnibus_install_options, Util.outdent!(<<-MSG)
        The 'chef_omnibus_install_options' attribute will be replaced by using
        'product_name' and 'channel' attributes.

        Note: 'product_name' must be set in order to use 'channel'
        until 'product_name' replaces 'require_chef_omnibus' as the default.

        # Deprecated Example #
        provisioner:
          chef_omnibus_install_options: -P chefdk -c current

        # New Usage #
        provisioner:
          product_name: chefdk
          channel: current
      MSG

      deprecate_config_for :install_msi_url, Util.outdent!(<<-MSG)
        The 'install_msi_url' will be relaced by the 'download_url' attribute.
        'download_url' will be applied to Bourne and Powershell download scripts.

        Note: 'product_name' must be set in order to use 'download_url'
        until 'product_name' replaces 'require_chef_omnibus' as the default.

        # New Usage #
        provisioner:
          product_name: <chef or chefdk>
          download_url: http://direct-download-url
      MSG

      deprecate_config_for :chef_metadata_url, Util.outdent!(<<-MSG)
        The 'chef_metadata_url' will be removed. The Windows metadata URL will be
        fully managed by using attribute settings.
      MSG

      # Reads the local Chef::Config object (if present).  We do this because
      # we want to start bring Chef config and ChefDK tool config closer
      # together.  For example, we want to configure proxy settings in 1
      # location instead of 3 configuration files.
      #
      # @param config [Hash] initial provided configuration
      def initialize(config = {})
        super(config)

        if defined?(ChefConfig::WorkstationConfigLoader)
          ChefConfig::WorkstationConfigLoader.new(config[:config_path]).load
        end
        # This exports any proxy config present in the Chef config to
        # appropriate environment variables, which Test Kitchen respects
        ChefConfig::Config.export_proxies if defined?(ChefConfig::Config.export_proxies)
      end

      def doctor(state)
        deprecated_config.each do |attr, msg|
          info("**** #{attr} deprecated\n#{msg}")
        end
      end

      # gives us the product version from either require_chef_omnibus or product_version
      # If the non-default (true) value of require_chef_omnibus is present use that
      # otherwise use config[:product_version] which defaults to :latest and is the actual
      # default for chef provisioners
      #
      # @return [String] version
      def product_version
        if !config[:require_chef_omnibus].is_a?(TrueClass)
          config[:require_chef_omnibus]
        else
          config[:product_version]
        end
      end

      # (see Base#check_license)
      def check_license
        name = config[:product_name] || "chef"
        version = product_version
        debug("Checking if we need to prompt for license acceptance on product: #{name} version: #{version}.")

        acceptor = LicenseAcceptance::Acceptor.new(logger: Kitchen.logger, provided: config[:chef_license])
        if acceptor.license_required?(name, version)
          debug("License acceptance required for #{name} version: #{version}. Prompting")
          license_name = acceptor.name_from_mixlib(name)
          begin
            acceptor.check_and_persist(license_name, version.to_s)
          rescue LicenseAcceptance::LicenseNotAcceptedError
            error("Cannot converge without accepting the Chef License. Set it in your kitchen.yml or using the CHEF_LICENSE environment variable")
            raise
          end
          config[:chef_license] ||= acceptor.acceptance_value
        end
      end

      # (see Base#create_sandbox)
      def create_sandbox
        super
        sanity_check_sandbox_options!
        Chef::CommonSandbox.new(config, sandbox_path, instance).populate
      end

      # (see Base#init_command)
      def init_command
        dirs = %w{
          cookbooks data data_bags environments roles clients
          encrypted_data_bag_secret
        }.sort.map { |dir| remote_path_join(config[:root_path], dir) }

        vars = if powershell_shell?
                 init_command_vars_for_powershell(dirs)
               else
                 init_command_vars_for_bourne(dirs)
               end

        prefix_command(shell_code_from_file(vars, "chef_base_init_command"))
      end

      # (see Base#install_command)
      def install_command
        return unless config[:require_chef_omnibus] || config[:product_name]
        return if config[:product_name] && config[:install_strategy] == "skip"
        prefix_command(sudo(install_script_contents))
      end

      private

      def last_exit_code
        "; exit $LastExitCode" if powershell_shell?
      end

      # @return [Hash] an option hash for the install commands
      # @api private
      def install_options
        add_omnibus_directory_option if instance.driver.cache_directory
        project = /\s*-P (\w+)\s*/.match(config[:chef_omnibus_install_options])
        {
          omnibus_url: config[:chef_omnibus_url],
          project: project.nil? ? nil : project[1],
          install_flags: config[:chef_omnibus_install_options],
          sudo_command: sudo_command,
        }.tap do |opts|
          opts[:root] = config[:chef_omnibus_root] if config.key? :chef_omnibus_root
          [:install_msi_url, :http_proxy, :https_proxy].each do |key|
            opts[key] = config[key] if config.key? key
          end
        end
      end

      # Verify if the "omnibus_dir_option" has already been passed, if so we
      # don't use the @driver.cache_directory
      #
      # @api private
      def add_omnibus_directory_option
        cache_dir_option = "#{omnibus_dir_option} #{instance.driver.cache_directory}"
        if config[:chef_omnibus_install_options].nil?
          config[:chef_omnibus_install_options] = cache_dir_option
        elsif config[:chef_omnibus_install_options].match(/\s*#{omnibus_dir_option}\s*/).nil?
          config[:chef_omnibus_install_options] << " " << cache_dir_option
        end
      end

      # @return [String] an absolute path to a Policyfile, relative to the
      #   kitchen root
      # @api private
      def policyfile
        policyfile_basename = config[:policyfile_path] || config[:policyfile] || "Policyfile.rb"
        File.join(config[:kitchen_root], policyfile_basename)
      end

      # @return [String] an absolute path to a Berksfile, relative to the
      #   kitchen root
      # @api private
      def berksfile
        File.join(config[:kitchen_root], "Berksfile")
      end

      # Generates a Hash with default values for a solo.rb or client.rb Chef
      # configuration file.
      #
      # @return [Hash] a configuration hash
      # @api private
      def default_config_rb # rubocop:disable Metrics/MethodLength
        root = config[:root_path].gsub("$env:TEMP", "\#{ENV['TEMP']\}")

        {
          node_name: instance.name,
          checksum_path: remote_path_join(root, "checksums"),
          file_cache_path: remote_path_join(root, "cache"),
          file_backup_path: remote_path_join(root, "backup"),
          cookbook_path: [
            remote_path_join(root, "cookbooks"),
            remote_path_join(root, "site-cookbooks"),
          ],
          data_bag_path: remote_path_join(root, "data_bags"),
          environment_path: remote_path_join(root, "environments"),
          node_path: remote_path_join(root, "nodes"),
          role_path: remote_path_join(root, "roles"),
          client_path: remote_path_join(root, "clients"),
          user_path: remote_path_join(root, "users"),
          validation_key: remote_path_join(root, "validation.pem"),
          client_key: remote_path_join(root, "client.pem"),
          chef_server_url: "http://127.0.0.1:8889",
          encrypted_data_bag_secret: remote_path_join(
            root, "encrypted_data_bag_secret"
          ),
          treat_deprecation_warnings_as_errors: config[:deprecations_as_errors],
        }
      end

      # Generates a rendered client.rb/solo.rb/knife.rb formatted file as a
      # String.
      #
      # @param data [Hash] a key/value pair hash of configuration
      # @return [String] a rendered Chef config file as a String
      # @api private
      def format_config_file(data)
        data.each.map do |attr, value|
          [attr, format_value(value)].join(" ")
        end.join("\n")
      end

      # Converts a Ruby object to a String interpretation suitable for writing
      # out to a client.rb/solo.rb/knife.rb file.
      #
      # @param obj [Object] an object
      # @return [String] a string representation
      # @api private
      def format_value(obj)
        if obj.is_a?(String) && obj =~ /^:/
          obj
        elsif obj.is_a?(String)
          %{"#{obj.gsub(/\\/, '\\\\\\\\')}"}
        elsif obj.is_a?(Array)
          %{[#{obj.map { |i| format_value(i) }.join(', ')}]}
        else
          obj.inspect
        end
      end

      # Generates the init command variables for Bourne shell-based platforms.
      #
      # @param dirs [Array<String>] directories
      # @return [String] shell variable lines
      # @api private
      def init_command_vars_for_bourne(dirs)
        [
          shell_var("sudo_rm", sudo("rm")),
          shell_var("dirs", dirs.join(" ")),
          shell_var("root_path", config[:root_path]),
        ].join("\n")
      end

      # Generates the init command variables for PowerShell-based platforms.
      #
      # @param dirs [Array<String>] directories
      # @return [String] shell variable lines
      # @api private
      def init_command_vars_for_powershell(dirs)
        [
          %{$dirs = @(#{dirs.map { |d| %{"#{d}"} }.join(', ')})},
          shell_var("root_path", config[:root_path]),
        ].join("\n")
      end

      # Load cookbook dependency resolver code, if required.
      #
      # (see Base#load_needed_dependencies!)
      def load_needed_dependencies!
        super
        if File.exist?(policyfile)
          debug("Policyfile found at #{policyfile}, using Policyfile to resolve cookbook dependencies")
          Chef::Policyfile.load!(logger: logger)
        elsif File.exist?(berksfile)
          debug("Berksfile found at #{berksfile}, using Berkshelf to resolve cookbook dependencies")
          Chef::Berkshelf.load!(logger: logger)
        end
      end

      # @return [String] contents of the install script
      # @api private
      def install_script_contents
        # by default require_chef_omnibus is set to true. Check config[:product_name] first
        # so that we can use it if configured.
        if config[:product_name]
          script_for_product
        elsif config[:require_chef_omnibus]
          script_for_omnibus_version
        end
      end

      # @return [String] contents of product based install script
      # @api private
      def script_for_product
        installer = Mixlib::Install.new({
          product_name: config[:product_name],
          product_version: config[:product_version],
          channel: config[:channel].to_sym,
          install_command_options: {
            install_strategy: config[:install_strategy],
          },
        }.tap do |opts|
          opts[:shell_type] = :ps1 if powershell_shell?
          [:platform, :platform_version, :architecture].each do |key|
            opts[key] = config[key] if config[key]
          end

          if config[:download_url]
            opts[:install_command_options][:download_url_override] = config[:download_url]
            opts[:install_command_options][:checksum] = config[:checksum] if config[:checksum]
          end

          if instance.driver.cache_directory
            download_dir_option = windows_os? ? :download_directory : :cmdline_dl_dir
            opts[:install_command_options][download_dir_option] = instance.driver.cache_directory
          end

          proxies = {}.tap do |prox|
            [:http_proxy, :https_proxy, :ftp_proxy, :no_proxy].each do |key|
              prox[key] = config[key] if config[key]
            end

            # install.ps1 only supports http_proxy
            prox.delete_if { |p| [:https_proxy, :ftp_proxy, :no_proxy].include?(p) } if powershell_shell?
          end

          opts[:install_command_options].merge!(proxies)
        end)
        config[:chef_omnibus_root] = installer.root
        if powershell_shell?
          installer.install_command
        else
          install_from_file(installer.install_command)
        end
      end

      # @return [String] Correct option per platform to specify the the
      #                  cache directory
      # @api private
      def omnibus_dir_option
        windows_os? ? "-download_directory" : "-d"
      end

      def install_from_file(command)
        install_file = "/tmp/chef-installer.sh"
        script = ["cat > #{install_file} <<\"EOL\""]
        script << command
        script << "EOL"
        script << "chmod +x #{install_file}"
        script << sudo(install_file)
        script.join("\n")
      end

      # @return [String] contents of version based install script
      # @api private
      def script_for_omnibus_version
        installer = Mixlib::Install::ScriptGenerator.new(
          config[:require_chef_omnibus], powershell_shell?, install_options)
        config[:chef_omnibus_root] = installer.root
        installer.install_command
      end

      # Hook used in subclasses to indicate support for policyfiles.
      #
      # @abstract
      # @return [Boolean]
      # @api private
      def supports_policyfile?
        false
      end

      # @return [void]
      # @raise [UserError]
      # @api private
      def sanity_check_sandbox_options!
        if (config[:policyfile_path] || config[:policyfile]) && !File.exist?(policyfile)
          raise UserError, "policyfile_path set in config "\
            "(#{config[:policyfile_path]} could not be found. " \
            "Expected to find it at full path #{policyfile} " \
        end
        if File.exist?(policyfile) && !supports_policyfile?
          raise UserError, "policyfile detected, but provisioner " \
            "#{self.class.name} doesn't support Policyfiles. " \
            "Either use a different provisioner, or delete/rename " \
            "#{policyfile}"
        end
      end

      # Writes a configuration file to the sandbox directory.
      # @api private
      def prepare_config_rb
        data = default_config_rb.merge(config[config_filename.tr(".", "_").to_sym])
        data = data.merge(named_run_list: config[:named_run_list]) if config[:named_run_list]

        info("Preparing #{config_filename}")
        debug("Creating #{config_filename} from #{data.inspect}")

        File.open(File.join(sandbox_path, config_filename), "wb") do |file|
          file.write(format_config_file(data))
        end

        prepare_config_idempotency_check(data) if config[:enforce_idempotency]
      end

      # Writes a configuration file to the sandbox directory
      # to check for idempotency of the run.
      # @api private
      def prepare_config_idempotency_check(data)
        handler_filename = "chef-client-fail-if-update-handler.rb"
        source = File.join(
          File.dirname(__FILE__), %w{.. .. .. support }, handler_filename
        )
        FileUtils.cp(source, File.join(sandbox_path, handler_filename))
        File.open(File.join(sandbox_path, "client_no_updated_resources.rb"), "wb") do |file|
          file.write(format_config_file(data))
          file.write("\n\n")
          file.write("handler_file = File.join(File.dirname(__FILE__), '#{handler_filename}')\n")
          file.write "Chef::Config.from_file(handler_file)\n"
        end
      end

      # Returns an Array of command line arguments for the chef client.
      #
      # @return [Array<String>] an array of command line arguments
      # @api private
      def chef_args(_config_filename)
        raise "You must override in sub classes!"
      end

      # Returns a filename for the configuration file
      # defaults to client.rb
      #
      # @return [String] a filename
      # @api private
      def config_filename
        "client.rb"
      end

      # Gives the command used to run chef
      # @api private
      def chef_cmd(base_cmd)
        if windows_os?
          separator = [
            "; if ($LastExitCode -ne 0) { ",
            "throw \"Command failed with exit code $LastExitCode.\" } ;",
          ].join
        else
          separator = " && "
        end
        chef_cmds(base_cmd).join(separator)
      end

      # Gives an array of command
      # @api private
      def chef_cmds(base_cmd)
        cmd = prefix_command(wrap_shell_code(
          [base_cmd, *chef_args(config_filename), last_exit_code].join(" ")
          .tap { |str| str.insert(0, reload_ps1_path) if windows_os? }
        ))

        cmds = [cmd].cycle(config[:multiple_converge].to_i).to_a

        if config[:enforce_idempotency]
          idempotent_cmd = prefix_command(wrap_shell_code(
            [base_cmd, *chef_args("client_no_updated_resources.rb"), last_exit_code].join(" ")
            .tap { |str| str.insert(0, reload_ps1_path) if windows_os? }
          ))
          cmds[-1] = idempotent_cmd
        end
        cmds
      end
    end
  end
end

module Kitchen

  module Provisioner

    module Chef
      # blah
      class BourneShell

        def initialize(use_sudo)
          @use_sudo = use_sudo
        end

        def name
          "bourne"
        end

        def chef_omnibus_root
          "/opt/chef"
        end

        def chef_solo_file
          "bin/chef-solo"
        end

        def chef_client_file
          "bin/chef-client"
        end

        def init_command(config)
          dirs = %w[cookbooks data data_bags environments roles clients].
            map { |dir| File.join(config[:root_path], dir) }.join(" ")
          lines = ["#{sudo("rm")} -rf #{dirs}", "mkdir -p #{config[:root_path]}"]

          wrap_command([dirs, lines].join("\n"))
        end

        def helper_file
          "chef_helpers.sh"
        end

        def install_function(version, config)
          pretty_version = case version
                           when "true" then "install only if missing"
                           when "latest" then "always install latest version"
                           else version
                           end
          install_flags = %w[latest true].include?(version) ? "" : "-v #{version}"
          if config[:chef_omnibus_install_options]
            install_flags += config[:chef_omnibus_install_options]
          end

          <<-INSTALL.gsub(/^ {10}/, "")
            if should_update_chef "#{config[:chef_omnibus_root]}" "#{version}" ; then
              echo "-----> Installing Chef Omnibus (#{pretty_version})"
              do_download #{config[:chef_omnibus_url]} /tmp/install.sh
              #{sudo("sh")} /tmp/install.sh #{install_flags}
            else
              echo "-----> Chef Omnibus installation detected (#{pretty_version})"
            fi
          INSTALL
        end

        def wrap_command(command)
          Util.wrap_command(command, name)
        end

        # Conditionally prefixes a command with a sudo command.
        #
        # @param command [String] command to be prefixed
        # @return [String] the command, conditionaly prefixed with sudo
        # @api private
        def sudo(script)
          @use_sudo ? "sudo -E #{script}" : script
        end
      end
    end
  end
end

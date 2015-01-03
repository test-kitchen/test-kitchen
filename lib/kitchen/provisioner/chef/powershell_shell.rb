module Kitchen

  module Provisioner

    module Chef
      # blah
      module PowershellShell

        def chef_omnibus_root
          "&$env:systemdrive\\opscode\\chef"
        end

        def chef_solo_file
          "bin\\chef-solo.bat"
        end

        def chef_client_file
          "bin\\chef-client.bat"
        end

        def init_command(config)
          cmd = <<-CMD.gsub(/^ {10}/, "")
            if (-Not (Test-Path #{config[:root_path]})) {
              mkdir #{config[:root_path]} | Out-Null
            }
          CMD

          dirs = %w[data data_bags environments roles clients].map do |dir|
            path = File.join(config[:root_path], dir)
            cmd << "if ( Test-Path #{path} ) { rm -r #{path} };"
          end

          wrap_command([dirs, cmd].join("\n"))
        end

        def chef_helper_file
          "chef_helpers.ps1"
        end

        def install_function(version, config)
          install_flags = %w[latest true].include?(version) ? "" : "v=#{version}"

          # If we have the default URL for UNIX then we change it for the Windows version.
          if config[:chef_omnibus_url] =~ %r{http[s]*://www.getchef.com/chef/install.sh}
            chef_url = "http://www.getchef.com/chef/install.msi?#{install_flags}"
          else
            # We use the one that comes from kitchen.yml
            chef_url = "#{config[:chef_omnibus_url]}?#{install_flags}"
          end

          # NOTE We use SYSTEMDRIVE because if we use TEMP the installation fails.
          <<-INSTALL.gsub(/^ {10}/, "")
            $chef_msi = $env:systemdrive + "\\chef.msi"

            If (should_update_chef #{version}) {
              Write-Host "-----> Installing Chef Omnibus (#{version})\n"
              download_chef "#{chef_url}" $chef_msi
              install_chef
            } else {
              Write-Host "-----> Chef Omnibus installation detected (#{version})\n"
            }
          INSTALL
        end
      end
    end
  end
end

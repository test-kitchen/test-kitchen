# -*- encoding: utf-8 -*-
#
# Author:: Matt Wrock (<matt@mattwrock.com>)
#
# Copyright (C) 2014, Matt Wrock
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

module Kitchen

  module Provisioner

    module Chef

      # Provides commands for interacting with chef on a test instance
      #
      # @author Matt Wrock <matt@mattwrock.com>
      module PowershellShell

        # The path to the root of a chef install
        #
        # @return [String] absolute path to chef root
        def chef_omnibus_root
          "&$env:systemdrive\\opscode\\chef"
        end

        # path to chef-solo relative to the chef_omnibus_root
        #
        # @return [String] path to chef solo
        def chef_solo_file
          "bin\\chef-solo.bat"
        end

        # path to chef-client relative to the chef_omnibus_root
        #
        # @return [String] path to chef client
        def chef_client_file
          "bin\\chef-client.bat"
        end

        # A command for initializing an instance for working with chef
        # the calling provisioner may have a omnibus root configured by
        # the user that is different from this module's chef_omnibus_root.
        #
        # @param root_path [String] root path to chef omnibus
        # @return [String] command to run on instance initializing
        # chef environment
        def init_command(root_path)
          cmd = <<-CMD.gsub(/^ {10}/, "")
            if (-Not (Test-Path "#{root_path}")) {
              mkdir "#{root_path}" | Out-Null
            }
          CMD

          dirs = %w[data data_bags environments roles clients].map do |dir|
            path = File.join(root_path, dir)
            cmd << "if ( Test-Path '#{path}' ) { rm -r '#{path}' };"
          end

          wrap_command([dirs, cmd].join("\n"))
        end

        # File name containing helper scripts for working with the chef
        # environment on the test instance.
        #
        # @return [String] helper file name
        def chef_helper_file
          "chef_helpers.ps1"
        end

        # Install script for the chef client on the test instance.
        #
        # @param version [String] the chef version to install
        # @param config [Hash] the calling provisioner's config
        # @option opts [String] :chef_omnibus_install_options install
        # options to pass to installer
        # @option opts [String] :chef_omnibus_root path to the chef omnibus root
        # @option opts [String] :chef_omnibus_url URL to download the chef installer
        # @return [String] command to install chef
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

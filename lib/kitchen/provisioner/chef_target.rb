#
# Author:: Thomas Heinen (<thomas.heinen@gmail.com>)
#
# Copyright (C) 2023, Thomas Heinen
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

require_relative "chef_infra"

module Kitchen
  module Provisioner
    # Chef Target provisioner.
    #
    # @author Thomas Heinen <thomas.heinen@gmail.com>
    class ChefTarget < ChefInfra
      MIN_VERSION_REQUIRED = '18.2.5'.freeze

      # TODO: Theoretically could adapt this to use Habitat for explicit version request
      default_config :install_strategy, "none"
      default_config :sudo, true

      def install_command; ""; end
      def init_command; ""; end
      def prepare_command; ""; end

      def chef_args(client_rb_filename)
        # Dummy execution to initialize and test remote connection (TODO: better?)
        connection = instance.remote_exec('')

        # TODO: Feels like the wrong spot to do this
        check_transport(connection)
        check_local_chef_client

        # TODO
        instance_name = instance.name
        credentials_file = File.join(kitchen_basepath, '.kitchen', instance_name + '.ini')
        File.write(credentials_file, connection.credentials_file)

        super.concat([
          "--target #{instance_name}",
          "--credentials #{credentials_file}",
          # "--log_level trace"
        ])
      end

      # TODO
      # - set `instance.transport` to `null` (avoid script execution)
      # - twist execution to run... differently

      def check_transport(connection)
        debug('Checking for active transport')

        unless connection.respond_to? 'train_uri'
          error('Chef Target Mode provisioner requires a Train-based transport like kitchen-transport-train')
          raise
        end

        debug('Kitchen transport responds to train_uri function call, as required')
      end

      def check_local_chef_client
        # - check for `chef-client` locally + right version
        debug('Checking for chef-client version')

        begin
          client_version = `chef-client -v`.chop.split(':')[-1]
        rescue Errno::ENOENT => e
          error("Error determining Chef Infra version: #{e.exception.message}")
          raise
        end

        minimum_version = Gem::Version.new(MIN_VERSION_REQUIRED)
        installed_version = Gem::Version.new(client_version)

        if installed_version < minimum_version
          error("Found Chef Infra version #{installed_version}, but require #{minimum_version} for Target Mode")
          raise
        end

        debug("Chef Infra found and version constraints match")
      end

      def kitchen_basepath
        instance.driver.config[:kitchen_root]
      end

      def create_sandbox
        super

        # Change config.rb to point to the local sandbox path, not to /tmp/kitchen
        config[:root_path] = sandbox_path
        prepare_config_rb
      end

      def call(state)
        remote_connection = instance.transport.connection(state)

        config[:uploads].to_h.each do |locals, remote|
          debug("Uploading #{Array(locals).join(", ")} to #{remote}")
          remote_connection.upload(locals.to_s, remote)
        end

        # no installation
        create_sandbox
        # no prepare command

        # TODO: in base transport - reimplement
        # execute_with_retry(
        #   run_command,
        #   config[:retry_on_exit_code],
        #   config[:max_retries],
        #   config[:wait_for_retry]
        # )

        # Stream output to logger (TODO: check if this sets exit code)
        require 'open3'
        stdout, _sterr, _exitcode = Open3.popen2e(run_command)
        Open3.popen2e(run_command) do |_stdin, output, _thread|
          output.each { |line| logger << line }
        end

        info("Downloading files from #{instance.to_str}")
        config[:downloads].to_h.each do |remotes, local|
          debug("Downloading #{Array(remotes).join(", ")} to #{local}")
          remote_connection.download(remotes, local)
        end
        debug("Download complete")
      rescue Kitchen::Transport::TransportFailed => ex
        raise ActionFailed, ex.message
      ensure
        cleanup_sandbox
      end
    end

    # Speed up Ohai for development by disabling plugins??
    # def default_config_rb
    #   default_config_rb.merge({
    #     ohai: {
    #       disabled_plugins: %i[
    #         Azure C DigitalOcean DMI Docker Elixir Erlang Eucalyptus Freebsd
    #         Gce Go Groovy Haskell Java Joyent Linode Lua Mono Nodejs Openstack
    #         Perl Php Powershell Rackspace Rust Scala Scaleway Shard Softlayer
    #         Virtualbox Vmware Zpools
    #       ]
    #     }
    #   })
    # end
  end
end

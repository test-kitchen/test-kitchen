# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, Fletcher Nichol
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

require 'benchmark'
require 'fog'

require 'kitchen'

module Kitchen

  module Driver

    # Amazon EC2 driver for Test Kitchen.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Ec2 < Kitchen::Driver::SSHBase

      default_config :region,             'us-east-1'
      default_config :availability_zone,  'us-east-1b'
      default_config :flavor_id,          'm1.small'
      default_config :groups,             ['default']
      default_config :tags,               { 'created-by' => 'test-kitchen' }
      default_config :username,           'root'

      required_config :aws_access_key_id
      required_config :aws_secret_access_key
      required_config :aws_ssh_key_id
      required_config :image_id

      def create(state)
        server = create_server
        state[:server_id] = server.id

        info("EC2 instance <#{state[:server_id]}> created.")
        server.wait_for { print "."; ready? } ; print "(server ready)"
        state[:hostname] = server.public_ip_address || server.private_ip_address
        wait_for_sshd(state[:hostname], config[:username]) ; print "(ssh ready)\n"
        debug("ec2:create '#{state[:hostname]}'")
      rescue Fog::Errors::Error, Excon::Errors::Error => ex
        raise ActionFailed, ex.message
      end

      def destroy(state)
        return if state[:server_id].nil?

        server = connection.servers.get(state[:server_id])
        server.destroy unless server.nil?
        info("EC2 instance <#{state[:server_id]}> destroyed.")
        state.delete(:server_id)
        state.delete(:hostname)
      end

      private

      def connection
        Fog::Compute.new(
          :provider               => :aws,
          :aws_access_key_id      => config[:aws_access_key_id],
          :aws_secret_access_key  => config[:aws_secret_access_key],
          :region                 => config[:region],
        )
      end

      def create_server
        debug_server_config

        connection.servers.create(
          :availability_zone  => config[:availability_zone],
          :groups             => config[:groups],
          :tags               => config[:tags],
          :flavor_id          => config[:flavor_id],
          :image_id           => config[:image_id],
          :key_name           => config[:aws_ssh_key_id],
          :subnet_id          => config[:subnet_id],
        )
      end

      def debug_server_config
        debug("ec2:region '#{config[:region]}'")
        debug("ec2:availability_zone '#{config[:availability_zone]}'")
        debug("ec2:flavor_id '#{config[:flavor_id]}'")
        debug("ec2:image_id '#{config[:image_id]}'")
        debug("ec2:groups '#{config[:groups]}'")
        debug("ec2:tags '#{config[:tags]}'")
        debug("ec2:key_name '#{config[:aws_ssh_key_id]}'")
        debug("ec2:subnet_id '#{config[:subnet_id]}'")
      end
    end
  end
end

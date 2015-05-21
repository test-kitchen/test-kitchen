# -*- encoding: utf-8 -*-
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

require "benchmark"
require "json"
require "aws"
require "kitchen"
require_relative "ec2_version"
require_relative "aws/client"
require_relative "aws/instance_generator"
require "aws-sdk-core/waiters/errors"

module Kitchen

  module Driver

    # Amazon EC2 driver for Test Kitchen.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Ec2 < Kitchen::Driver::Base # rubocop:disable Metrics/ClassLength

      kitchen_driver_api_version 2

      plugin_version Kitchen::Driver::EC2_VERSION

      default_config :region,             ENV["AWS_REGION"] || "us-east-1"
      default_config :shared_credentials_profile, nil
      default_config :availability_zone,  nil
      default_config :flavor_id,          nil
      default_config :instance_type,      nil
      default_config :ebs_optimized,      false
      default_config :security_group_ids, nil
      default_config :tags,                "created-by" => "test-kitchen"
      default_config :user_data,          nil
      default_config :private_ip_address, nil
      default_config :iam_profile_name,   nil
      default_config :price,              nil
      default_config :retryable_tries,    60
      default_config :retryable_sleep,    5
      default_config :aws_access_key_id,  nil
      default_config :aws_secret_access_key, nil
      default_config :aws_session_token,  nil
      default_config :aws_ssh_key_id,     ENV["AWS_SSH_KEY_ID"]
      default_config :image_id do |driver|
        driver.default_ami
      end
      default_config :username,            nil
      default_config :associate_public_ip, nil
      default_config :interface,           nil

      required_config :aws_ssh_key_id
      required_config :image_id

      def self.validation_warn(driver, old_key, new_key)
        driver.warn "WARN: The driver[#{driver.class.name}] config key `#{old_key}` " \
          "is deprecated, please use `#{new_key}`"
      end

      # TODO: remove these in the next major version of TK
      deprecated_configs = [:ebs_volume_size, :ebs_delete_on_termination, :ebs_device_name]
      deprecated_configs.each do |d|
        validations[d] = lambda do |attr, val, driver|
          unless val.nil?
            validation_warn(driver, attr, "block_device_mappings")
          end
        end
      end
      validations[:ssh_key] = lambda do |attr, val, driver|
        unless val.nil?
          validation_warn(driver, attr, "transport.ssh_key")
        end
      end
      validations[:ssh_timeout] = lambda do |attr, val, driver|
        unless val.nil?
          validation_warn(driver, attr, "transport.connection_timeout")
        end
      end
      validations[:ssh_retries] = lambda do |attr, val, driver|
        unless val.nil?
          validation_warn(driver, attr, "transport.connection_retries")
        end
      end
      validations[:username] = lambda do |attr, val, driver|
        unless val.nil?
          validation_warn(driver, attr, "transport.username")
        end
      end
      validations[:flavor_id] = lambda do |attr, val, driver|
        unless val.nil?
          validation_warn(driver, attr, "instance_type")
        end
      end

      default_config :block_device_mappings, nil
      validations[:block_device_mappings] = lambda do |_attr, val, _driver|
        unless val.nil?
          val.each do |bdm|
            unless bdm.keys.include?(:ebs_volume_size) &&
                bdm.keys.include?(:ebs_delete_on_termination) &&
                bdm.keys.include?(:ebs_device_name)
              raise "Every :block_device_mapping must include the keys :ebs_volume_size, " \
                ":ebs_delete_on_termination and :ebs_device_name"
            end
          end
        end
      end

      # The access key/secret are now using the priority list AWS uses
      # Providing these inside the .kitchen.yml is no longer recommended
      validations[:aws_access_key_id] = lambda do |attr, val, driver|
        unless val.nil?
          driver.warn "WARN: #{attr} has been deprecated, please use " \
            "ENV['AWS_ACCESS_KEY_ID'] or ~/.aws/credentials.  See " \
            "the README for more details"
        end
      end
      validations[:aws_secret_access_key] = lambda do |attr, val, driver|
        unless val.nil?
          driver.warn "WARN: #{attr} has been deprecated, please use " \
            "ENV['AWS_SECRET_ACCESS_KEY'] or ~/.aws/credentials.  See " \
            "the README for more details"
        end
      end
      validations[:aws_session_token] = lambda do |attr, val, driver|
        unless val.nil?
          driver.warn "WARN: #{attr} has been deprecated, please use " \
            "ENV['AWS_SESSION_TOKEN'] or ~/.aws/credentials.  See " \
            "the README for more details"
        end
      end

      # A lifecycle method that should be invoked when the object is about
      # ready to be used. A reference to an Instance is required as
      # configuration dependant data may be access through an Instance. This
      # also acts as a hook point where the object may wish to perform other
      # last minute checks, validations, or configuration expansions.
      #
      # @param instance [Instance] an associated instance
      # @return [self] itself, for use in chaining
      # @raise [ClientError] if instance parameter is nil
      def finalize_config!(instance)
        super

        if config[:availability_zone].nil?
          config[:availability_zone] = config[:region] + "b"
        end
        # TODO: when we get rid of flavor_id, move this to a default
        if config[:instance_type].nil?
          config[:instance_type] = config[:flavor_id] || "m1.small"
        end

        self
      end

      def create(state) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        copy_deprecated_configs(state)
        return if state[:server_id]

        info(Kitchen::Util.outdent!(<<-END))
          Creating <#{state[:server_id]}>...
          If you are not using an account that qualifies under the AWS
          free-tier, you may be charged to run these suites. The charge
          should be minimal, but neither Test Kitchen nor its maintainers
          are responsible for your incurred costs.
        END

        if config[:price]
          # Spot instance when a price is set
          server = submit_spot(state)
        else
          # On-demand instance
          server = submit_server
        end
        info("Instance <#{server.id}> requested.")
        tag_server(server)

        state[:server_id] = server.id
        info("EC2 instance <#{state[:server_id]}> created.")
        wait_log = proc do |attempts|
          c = attempts * config[:retryable_sleep]
          t = config[:retryable_tries] * config[:retryable_sleep]
          info "Waited #{c}/#{t}s for instance <#{state[:server_id]}> to become ready."
        end
        begin
          server = server.wait_until(
            :max_attempts => config[:retryable_tries],
            :delay => config[:retryable_sleep],
            :before_attempt => wait_log
          ) do |s|
            hostname = hostname(s, config[:interface])
            # Euca instances often report ready before they have an IP
            s.exists? && s.state.name == "running" && !hostname.nil? && hostname != "0.0.0.0"
          end
        rescue ::Aws::Waiters::Errors::WaiterFailed
          error("Ran out of time waiting for the server with id [#{state[:server_id]}]" \
            " to become ready, attempting to destroy it")
          destroy(state)
          raise
        end

        info("EC2 instance <#{state[:server_id]}> ready.")
        state[:hostname] = hostname(server)
        instance.transport.connection(state).wait_until_ready
        create_ec2_json(state)
        debug("ec2:create '#{state[:hostname]}'")
      end

      def destroy(state)
        return if state[:server_id].nil?

        server = ec2.get_instance(state[:server_id])
        unless server.nil?
          instance.transport.connection(state).close
          server.terminate
        end
        if state[:spot_request_id]
          debug("Deleting spot request <#{state[:server_id]}>")
          ec2.client.cancel_spot_instance_requests(
            :spot_instance_request_ids => [state[:spot_request_id]]
          )
        end
        info("EC2 instance <#{state[:server_id]}> destroyed.")
        state.delete(:server_id)
        state.delete(:hostname)
      end

      def default_ami
        region = amis["regions"][config[:region]]
        region && region[instance.platform.name]
      end

      def ec2
        @ec2 ||= Aws::Client.new(
          config[:region],
          config[:shared_credentials_profile],
          config[:aws_access_key_id],
          config[:aws_secret_access_key],
          config[:aws_session_token]
        )
      end

      def instance_generator
        @instance_generator ||= Aws::InstanceGenerator.new(config, ec2)
      end

      # This copies transport config from the current config object into the
      # state.  This relies on logic in the transport that merges the transport
      # config with the current state object, so its a bad coupling.  But we
      # can get rid of this when we get rid of these deprecated configs!
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def copy_deprecated_configs(state)
        if config[:ssh_timeout]
          state[:connection_timeout] = config[:ssh_timeout]
        end
        if config[:ssh_retries]
          state[:connection_retries] = config[:ssh_retries]
        end
        if config[:username]
          state[:username] = config[:username]
        elsif instance.transport[:username] == instance.transport.class.defaults[:username]
          # If the transport has the default username, copy it from amis.json
          # This duplicated old behavior but I hate amis.json
          ami_username = amis["usernames"][instance.platform.name]
          state[:username] = ami_username if ami_username
        end
        if config[:ssh_key]
          state[:ssh_key] = config[:ssh_key]
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # Fog AWS helper for creating the instance
      def submit_server
        debug("Creating EC2 Instance..")
        instance_data = instance_generator.ec2_instance_data
        instance_data[:min_count] = 1
        instance_data[:max_count] = 1
        ec2.create_instance(instance_data)
      end

      def submit_spot(state) # rubocop:disable Metrics/AbcSize
        debug("Creating EC2 Spot Instance..")
        request_data = {}
        request_data[:spot_price] = config[:price].to_s
        request_data[:launch_specification] = instance_generator.ec2_instance_data

        response = ec2.client.request_spot_instances(request_data)
        spot_request_id = response[:spot_instance_requests][0][:spot_instance_request_id]
        # deleting the instance cancels the request, but deleting the request
        # does not affect the instance
        state[:spot_request_id] = spot_request_id
        ec2.client.wait_until(
          :spot_instance_request_fulfilled,
          :spot_instance_request_ids => [spot_request_id]
        ) do |w|
          w.max_attempts = config[:retryable_tries]
          w.delay = config[:retryable_sleep]
          w.before_attempt do |attempts|
            c = attempts * config[:retryable_sleep]
            t = config[:retryable_tries] * config[:retryable_sleep]
            info "Waited #{c}/#{t}s for spot request <#{spot_request_id}> to become fulfilled."
          end
        end
        ec2.get_instance_from_spot_request(spot_request_id)
      end

      def tag_server(server)
        tags = []
        config[:tags].each do |k, v|
          tags << { :key => k, :value => v }
        end
        server.create_tags(:tags => tags)
      end

      def amis
        @amis ||= begin
          json_file = File.join(File.dirname(__FILE__),
            %w[.. .. .. data amis.json])
          JSON.load(IO.read(json_file))
        end
      end

      #
      # Ordered mapping from config name to Fog name.  Ordered by preference
      # when looking up hostname.
      #
      INTERFACE_TYPES =
        {
          "dns" => "public_dns_name",
          "public" => "public_ip_address",
          "private" => "private_ip_address"
        }

      #
      # Lookup hostname of provided server.  If interface_type is provided use
      # that interface to lookup hostname.  Otherwise, try ordered list of
      # options.
      #
      def hostname(server, interface_type = nil)
        if interface_type
          interface_type = INTERFACE_TYPES.fetch(interface_type) do
            raise Kitchen::UserError, "Invalid interface [#{interface_type}]"
          end
          server.send(interface_type)
        else
          potential_hostname = nil
          INTERFACE_TYPES.values.each do |type|
            potential_hostname ||= server.send(type)
            # AWS returns an empty string if the dns name isn't populated yet
            potential_hostname = nil if potential_hostname == ""
          end
          potential_hostname
        end
      end

      def create_ec2_json(state)
        instance.transport.connection(state).execute(
          "sudo mkdir -p /etc/chef/ohai/hints;sudo touch /etc/chef/ohai/hints/ec2.json"
        )
      end

    end
  end
end

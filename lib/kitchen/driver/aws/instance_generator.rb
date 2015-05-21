# -*- encoding: utf-8 -*-
#
# Author:: Tyler Ball (<tball@chef.io>)
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

require "kitchen/logging"

module Kitchen

  module Driver

    class Aws

      # A class for encapsulating the instance payload logic
      #
      # @author Tyler Ball <tball@chef.io>
      class InstanceGenerator

        include Logging

        attr_reader :config, :ec2

        def initialize(config, ec2)
          @config = config
          @ec2 = ec2
        end

        # Transform the provided config into the hash to send to AWS.  Some fields
        # can be passed in null, others need to be ommitted if they are null
        def ec2_instance_data # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
          i = {
            :placement => {
              :availability_zone          => config[:availability_zone]
            },
            :instance_type                => config[:instance_type],
            :ebs_optimized                => config[:ebs_optimized],
            :image_id                     => config[:image_id],
            :key_name                     => config[:aws_ssh_key_id],
            :subnet_id                    => config[:subnet_id],
            :private_ip_address           => config[:private_ip_address]
          }
          i[:block_device_mappings] = block_device_mappings unless block_device_mappings.empty?
          i[:security_group_ids] = config[:security_group_ids] if config[:security_group_ids]
          i[:user_data] = prepared_user_data if prepared_user_data
          if config[:iam_profile_name]
            i[:iam_instance_profile] = { :name => config[:iam_profile_name] }
          end
          if !config.fetch(:associate_public_ip, nil).nil?
            i[:network_interfaces] =
              [{
                :device_index => 0,
                :associate_public_ip_address => config[:associate_public_ip]
              }]
            # If specifying `:network_interfaces` in the request, you must specify the
            # subnet_id in the network_interfaces block and not at the top level
            if config[:subnet_id]
              i[:network_interfaces][0][:subnet_id] = i.delete(:subnet_id)
            end
          end
          i
        end

        # Transforms the provided config into the appropriate hash for creating a BDM
        # in AWS
        def block_device_mappings # rubocop:disable all
          return @bdms if @bdms
          bdms = config[:block_device_mappings] || []
          if bdms.empty?
            if config[:ebs_volume_size] || config.fetch(:ebs_delete_on_termination, nil) ||
                config[:ebs_device_name] || config[:ebs_volume_type]
              # If the user didn't supply block_device_mappings but did supply
              # the old configs, copy them into the block_device_mappings array correctly
              # TODO: remove this logic when we remove the deprecated values
              bdms << {
                :ebs_volume_size => config[:ebs_volume_size] || 8,
                :ebs_delete_on_termination => config.fetch(:ebs_delete_on_termination, true),
                :ebs_device_name => config[:ebs_device_name] || "/dev/sda1",
                :ebs_volume_type => config[:ebs_volume_type] || "standard"
              }
            end
          end

          # Convert the provided keys to what AWS expects
          bdms = bdms.map do |bdm|
            b = {
              :ebs => {
                :volume_size           => bdm[:ebs_volume_size],
                :delete_on_termination => bdm[:ebs_delete_on_termination]
              },
              :device_name             => bdm[:ebs_device_name]
            }
            b[:ebs][:volume_type] = bdm[:ebs_volume_type] if bdm[:ebs_volume_type]
            b[:ebs][:snapshot_id] = bdm[:ebs_snapshot_id] if bdm[:ebs_snapshot_id]
            b[:virtual_name] = bdm[:ebs_virtual_name] if bdm[:ebs_virtual_name]
            b
          end

          debug_if_root_device(bdms)

          @bdms = bdms
        end

        # If the provided bdms match the root device in the AMI, emit log that
        # states this
        def debug_if_root_device(bdms)
          image_id = config[:image_id]
          image = ec2.resource.image(image_id)
          begin
            root_device_name = image.root_device_name
          rescue ::Aws::EC2::Errors::InvalidAMIIDNotFound
            # Not raising here because AWS will give a more meaningful message
            # when we try to create the instance
            return
          end
          bdms.find { |bdm|
            if bdm[:device_name] == root_device_name
              info("Overriding root device [#{root_device_name}] from image [#{image_id}]")
            end
          }
        end

        def prepared_user_data
          # If user_data is a file reference, lets read it as such
          unless @user_data
            if config[:user_data] && File.file?(config[:user_data])
              @user_data = File.read(config[:user_data])
            else
              @user_data = config[:user_data]
            end
          end
          @user_data
        end

      end

    end

  end

end

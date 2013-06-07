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

module Kitchen

  # A Chef run_list and attribute hash that will be used in a convergence
  # integration.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Suite

    # @return [String] logical name of this suite
    attr_reader :name

    # @return [Array] Array of Chef run_list items
    attr_reader :run_list

    # @return [Hash] Hash of Chef node attributes
    attr_reader :attributes

    # @return [Array] Array of names of excluded platforms
    attr_reader :excludes

    # @return [String] local path to the suite's data bags, or nil if one does
    #   not exist
    attr_reader :data_bags_path

    # @return [String] local path to the suite's encrypted data bag secret
    #   key path, or nil if one does not exist
    attr_reader :encrypted_data_bag_secret_key_path

    # @return [String] local path to the suite's roles, or nil if one does
    #   not exist
    attr_reader :roles_path

    # @return [String] local path to the suite's nodes, or nil if one does
    #   not exist
    attr_reader :nodes_path

    # Constructs a new suite.
    #
    # @param [Hash] options configuration for a new suite
    # @option options [String] :name logical name of this suit (**Required**)
    # @option options [String] :run_list Array of Chef run_list items
    #   (**Required**)
    # @option options [Hash] :attributes Hash of Chef node attributes
    # @option options [String] :excludes Array of names of excluded platforms
    # @option options [String] :data_bags_path path to data bags
    # @option options [String] :roles_path path to roles
    # @option options [String] :nodes_path path to nodes
    # @option options [String] :encrypted_data_bag_secret_key_path path to
    #   secret key file
    def initialize(options = {})
      validate_options(options)

      @name = options[:name]
      @run_list = options[:run_list]
      @attributes = options[:attributes] || Hash.new
      @excludes = options[:excludes]     || Array.new
      @data_bags_path = options[:data_bags_path]
      @roles_path = options[:roles_path]
      @nodes_path = options[:nodes_path]
      @encrypted_data_bag_secret_key_path = options[:encrypted_data_bag_secret_key_path]
    end

    private

    def validate_options(opts)
      [:name].each do |k|
        raise ClientError, "Suite#new requires option :#{k}" if opts[k].nil?
      end
    end
  end
end

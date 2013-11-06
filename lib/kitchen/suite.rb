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

    # @return [Array] Array of names of excluded platforms
    attr_reader :excludes

    # @return [Array] Array of names of only included platforms
    attr_reader :includes

    # @return [Hash] suite specific driver_config hash
    attr_reader :driver_config

    # Constructs a new suite.
    #
    # @param [Hash] options configuration for a new suite
    # @option options [String] :name logical name of this suit (**Required**)
    # @option options [String] :excludes Array of names of excluded platforms
    # @option options [String] :includes Array of names of only included
    #   platforms
    def initialize(options = {})
      options = options.dup
      validate_options(options)

      @name = options.delete(:name)
      @excludes = Array(options[:excludes])
      @includes = Array(options[:includes])
      @driver_config = options.delete(:driver_config) || {}
      @data = options
    end

    # Extra suite methods used for accessing Chef data such as a run list,
    # node attributes, etc.
    module Cheflike

      # @return [Array] Array of Chef run_list items
      def run_list
        Array(data[:run_list])
      end

      # @return [Hash] Hash of Chef node attributes
      def attributes
        data[:attributes] || Hash.new
      end

      # @return [String] local path to the suite's data bags, or nil if one
      #   does not exist
      def data_bags_path
        data[:data_bags_path]
      end

      # @return [String] local path to the suite's encrypted data bag secret
      #   key path, or nil if one does not exist
      def encrypted_data_bag_secret_key_path
        data[:encrypted_data_bag_secret_key_path]
      end

      # @return [String] local path to the suite's roles, or nil if one does
      #   not exist
      def roles_path
        data[:roles_path]
      end

      # @return [String] local path to the suite's nodes, or nil if one does
      #   not exist
      def nodes_path
        data[:nodes_path]
      end

      # @return [String] local path to the suite's environments, or nil if one does
      #   not exist
      def environments_path
        data[:environments_path]
      end

      # @return [String] the suite's environment, or nil if one does
      #   not exist
      def environment
        data[:environment]
      end

    end

    # Extra suite methods used for accessing Puppet data such as a manifest.
    module Puppetlike

      def manifest
      end
    end

    private

    attr_reader :data

    def validate_options(opts)
      [:name].each do |k|
        raise ClientError, "Suite#new requires option :#{k}" if opts[k].nil?
      end
    end
  end
end

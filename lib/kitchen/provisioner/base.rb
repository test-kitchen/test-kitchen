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

require 'kitchen/lazy_hash'

module Kitchen

  module Provisioner

    # Base class for a provisioner.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Base

      include Logging

      attr_accessor :instance

      def initialize(config = {})
        @config = LazyHash.new(config, self)
        self.class.defaults.each do |attr, value|
          @config[attr] = value unless @config.has_key?(attr)
        end
      end

      def instance=(instance)
        @instance = instance
        expand_paths!
        load_needed_dependencies!
      end

      # Returns the name of this driver, suitable for display in a CLI.
      #
      # @return [String] name of this driver
      def name
        self.class.name.split('::').last
      end

      # Provides hash-like access to configuration keys.
      #
      # @param attr [Object] configuration key
      # @return [Object] value at configuration key
      def [](attr)
        config[attr]
      end

      # Returns an array of configuration keys.
      #
      # @return [Array] array of configuration keys
      def config_keys
        config.keys
      end

      def init_command ; end

      def install_command ; end

      def prepare_command ; end

      def run_command ; end

      def create_sandbox
        @sandbox_path = Dir.mktmpdir("#{instance.name}-sandbox-")
        File.chmod(0755, sandbox_path)
        info("Preparing files for transfer")
        debug("Creating local sandbox in #{sandbox_path}")
      end

      def sandbox_path
        @sandbox_path || (raise ClientError, "Sandbox directory has not yet " +
          "been created. Please run #{self.class}#create_sandox before " +
          "trying to access the path.")
      end

      def cleanup_sandbox
        return if sandbox_path.nil?

        debug("Cleaning up local sandbox in #{sandbox_path}")
        FileUtils.rmtree(sandbox_path)
      end

      # Returns a Hash of configuration and other useful diagnostic information.
      #
      # @return [Hash] a diagnostic hash
      def diagnose
        config_keys.sort.reduce({}) { |result, key| result[k] = config[k]; result }
      end

      def calculate_path(path, type = :directory)
        base = config[:test_base_path]
        candidates = []
        candidates << File.join(base, instance.suite.name, path)
        candidates << File.join(base, path)
        candidates << File.join(Dir.pwd, path)

        candidates.find do |c|
          type == :directory ? File.directory?(c) : File.file?(c)
        end
      end

      def calculate_path(path, type = :directory)
        base = config[:test_base_path]
        candidates = []
        candidates << File.join(base, instance.suite.name, path)
        candidates << File.join(base, path)
        candidates << File.join(Dir.pwd, path)

        candidates.find do |c|
          type == :directory ? File.directory?(c) : File.file?(c)
        end
      end

      protected

      attr_reader :config

      def expand_paths!
        expanded_paths = LazyHash.new(self.class.expanded_paths, self).to_hash

        expanded_paths.each do |key, should_expand|
          if should_expand && !config[key].nil?
            config[key] = File.expand_path(config[key], config[:kitchen_root])
          end
        end
      end

      def load_needed_dependencies! ; end

      def logger
        instance ? instance.logger : Kitchen.logger
      end

      def sudo(script)
        config[:sudo] ? "sudo -E #{script}" : script
      end

      def self.defaults
        @defaults ||= Hash.new.merge(super_defaults)
      end

      def self.super_defaults
        klass = self.superclass

        if klass.respond_to?(:defaults)
          klass.defaults
        else
          Hash.new
        end
      end

      def self.default_config(attr, value = nil, &block)
        defaults[attr] = block_given? ? block : value
      end

      def self.expanded_paths
        @expanded_paths ||= Hash.new.merge(super_expanded_paths)
      end

      def self.super_expanded_paths
        klass = self.superclass

        if klass.respond_to?(:expanded_paths)
          klass.expanded_paths
        else
          Hash.new
        end
      end

      def self.expand_path_for(attr, value = true, &block)
        expanded_paths[attr] = block_given? ? block : value
      end

      default_config :root_path, "/tmp/kitchen"
      default_config :sudo, true

      expand_path_for :test_base_path
    end
  end
end

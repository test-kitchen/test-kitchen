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

require 'erb'
require 'vendor/hash_recursive_merge'
require 'safe_yaml'

module Kitchen

  module Loader

    # YAML file loader for Test Kitchen configuration. This class is
    # responisble for parsing the main YAML file and the local YAML if it
    # exists. Local file configuration will win over the default configuration.
    # The client of this class should not require any YAML loading or parsing
    # logic.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class YAML

      attr_reader :config_file

      # Creates a new loader that can parse and load YAML files.
      #
      # @param config_file [String] path to Kitchen config YAML file
      # @param options [Hash] configuration for a new loader
      # @option options [String] :process_erb whether or not to process YAML
      #   through an ERB processor (default: `true`)
      # @option options [String] :process_local whether or not to process a
      #   local kitchen YAML file, if it exists (default: `true`)
      def initialize(config_file = nil, options = {})
        @config_file = File.expand_path(config_file || default_config_file)
        @process_erb = options.fetch(:process_erb, true)
        @process_local = options.fetch(:process_local, true)
        @process_global = options.fetch(:process_global, true)
      end

      # Reads, parses, and merges YAML configuration files and returns a Hash
      # of tne merged data.
      #
      # @return [Hash] merged configuration data
      def read
        if ! File.exists?(config_file)
          raise UserError, "Kitchen YAML file #{config_file} does not exist."
        end

        Util.symbolized_hash(combined_hash)
      end

      # Returns a Hash of configuration and other useful diagnostic information.
      #
      # @return [Hash] a diagnostic hash
      def diagnose
        result = Hash.new
        result[:proces_erb] = @process_erb
        result[:process_local] = @process_local
        result[:process_global] = @process_global
        if File.exists?(global_config_file)
          result[:global_config] =
            { :filename => global_config_file, :raw_data => global_yaml }
        end
        result[:project_config] =
          { :filename => config_file, :raw_data => yaml }
        if File.exists?(local_config_file)
          result[:local_config] =
            { :filename => local_config_file, :raw_data => local_yaml }
        end
        result[:combined_config] = { :raw_data => combined_hash }
        result
      end

      protected

      def default_config_file
        File.join(Dir.pwd, '.kitchen.yml')
      end

      def combined_hash
        y = @process_local ? yaml.rmerge(local_yaml) : yaml
        @process_global ? y.rmerge(global_yaml) : y
      rescue NoMethodError
        raise UserError, "Error merging #{File.basename(config_file)} and" +
          "#{File.basename(local_config_file)}"
      end

      def yaml
        parse_yaml_string(yaml_string(config_file), config_file)
      end

      def local_yaml
        parse_yaml_string(yaml_string(local_config_file), local_config_file)
      end

      def global_yaml
        parse_yaml_string(yaml_string(global_config_file), global_config_file)
      end

      def yaml_string(file)
        string = read_file(file)

        @process_erb ? ERB.new(string).result : string
      end

      def read_file(file)
        File.exists?(file.to_s) ? IO.read(file) : ""
      end

      def local_config_file
        config_file.sub(/(#{File.extname(config_file)})$/, '.local\1')
      end

      def global_config_file
        File.join(File.expand_path(ENV["HOME"]), ".kitchen", "config.yml")
      end

      def parse_yaml_string(string, file_name)
        return Hash.new if string.nil? || string.empty?

        ::YAML.safe_load(string) || Hash.new
      rescue SyntaxError, Psych::SyntaxError
        raise UserError, "Error parsing #{file_name}"
      end
    end
  end
end

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

require "erb"
require "vendor/hash_recursive_merge"

if RUBY_VERSION <= "1.9.3"
  # ensure that Psych and not Syck is used for Ruby 1.9.2
  require "yaml"
  YAML::ENGINE.yamler = "psych"
end
require "safe_yaml/load"

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

      # Creates a new loader that can parse and load YAML files.
      #
      # @param options [Hash] configuration for a new loader
      # @option options [String] :project_config path to the Kitchen
      #   config YAML file (default: `./.kitchen.yml`)
      # @option options [String] :local_config path to the Kitchen local
      #   config YAML file (default: `./.kitchen.local.yml`)
      # @option options [String] :local_config path to the Kitchen global
      #   config YAML file (default: `$HOME/.kitchen/config.yml`)
      # @option options [String] :process_erb whether or not to process YAML
      #   through an ERB processor (default: `true`)
      # @option options [String] :process_local whether or not to process a
      #   local kitchen YAML file, if it exists (default: `true`)
      def initialize(options = {})
        @config_file =
          File.expand_path(options[:project_config] || default_config_file)
        @local_config_file =
          File.expand_path(options[:local_config] || default_local_config_file)
        @global_config_file =
          File.expand_path(options[:global_config] || default_global_config_file)

        @process_erb = options.fetch(:process_erb, true)
        @process_local = options.fetch(:process_local, true)
        @process_global = options.fetch(:process_global, true)
      end

      # Reads, parses, and merges YAML configuration files and returns a Hash
      # of tne merged data.
      #
      # @return [Hash] merged configuration data
      def read
        if !File.exist?(config_file)
          raise UserError, "Kitchen YAML file #{config_file} does not exist."
        end

        Util.symbolized_hash(combined_hash)
      end

      # Returns a Hash of configuration and other useful diagnostic information.
      #
      # @return [Hash] a diagnostic hash
      def diagnose
        result = Hash.new
        result[:process_erb] = @process_erb
        result[:process_local] = @process_local
        result[:process_global] = @process_global
        result[:global_config] = diagnose_component(:global_yaml, global_config_file)
        result[:project_config] = diagnose_component(:yaml, config_file)
        result[:local_config] = diagnose_component(:local_yaml, local_config_file)
        result[:combined_config] = diagnose_component(:combined_hash)
        result
      end

      private

      # @return [String] the absolute path to the Kitchen config YAML file
      # @api private
      attr_reader :config_file

      # @return [String] the absolute path to the Kitchen local config YAML
      #   file
      # @api private
      attr_reader :local_config_file

      # @return [String] the absolute path to the Kitchen global config YAML
      #   file
      # @api private
      attr_reader :global_config_file

      # Performed a prioritized recursive merge of several source Hashes and
      # returns a new merged Hash. There are 3 sources of configuration data:
      #
      # 1. global config
      # 2. local config
      # 3. project config
      #
      # The merge order is 3 -> 2 -> 1, meaning that the highest number in the
      # above list has merge precedence over any lower numbered source.
      #
      # @return [Hash] a new merged Hash
      # @api private
      def combined_hash
        y = if @process_local
          normalize(yaml).rmerge(normalize(local_yaml))
        else
          normalize(yaml)
        end
        @process_global ? y.rmerge(normalize(global_yaml)) : y
      end

      # Loads and returns the Kitchen config YAML as a Hash.
      #
      # @return [Hash] the config hash
      # @api private
      def yaml
        parse_yaml_string(yaml_string(config_file), config_file)
      end

      # Loads and returns the Kitchen local config YAML as a Hash.
      #
      # @return [Hash] the config hash
      # @api private
      def local_yaml
        parse_yaml_string(yaml_string(local_config_file), local_config_file)
      end

      # Loads and returns the Kitchen global config YAML as a Hash.
      #
      # @return [Hash] the config hash
      # @api private
      def global_yaml
        parse_yaml_string(yaml_string(global_config_file), global_config_file)
      end

      # Loads a file to a string and optionally passes it through an ERb
      # process.
      #
      # @return [String] a file's contents as a string
      # @api private
      def yaml_string(file)
        string = read_file(file)

        @process_erb ? process_erb(string, file) : string
      end

      # Passes a string through ERb to evaulate any ERb blocks.
      #
      # @param string [String] the string to process
      # @param file [String] an absolute path to the file represented as the
      #   passed in string, used for error reporting
      # @return [String] a new string, passed through an ERb process
      # @raise [UserError] if an ERb parsing error occurs
      # @api private
      def process_erb(string, file)
        ERB.new(string).result
      rescue => e
        raise UserError, "Error parsing ERB content in #{file} " \
          "(#{e.class}: #{e.message}).\n" \
          "Please run `kitchen diagnose --no-instances --loader' to help " \
          "debug your issue."
      end

      # Reads a file and returns its contents as a string.
      #
      # @param file [String] a path to a file
      # @return [String] the files contents, or an empty string if the file
      #   does not exist
      # @api private
      def read_file(file)
        File.exist?(file.to_s) ? IO.read(file) : ""
      end

      # Determines the default absolute path to the Kitchen config YAML file,
      # based on current working directory.
      #
      # @return [String] an absolute path to a Kitchen config YAML file
      # @api private
      def default_config_file
        File.join(Dir.pwd, ".kitchen.yml")
      end

      # Determines the default absolute path to the Kitchen local YAML file,
      # based on the base Kitchen config YAML file.
      #
      # @return [String] an absolute path to a Kitchen local YAML file
      # @api private
      def default_local_config_file
        config_file.sub(/(#{File.extname(config_file)})$/, '.local\1')
      end

      # Determines the default absolute path to the Kitchen global YAML file,
      # based on the base Kitchen config YAML file.
      #
      # @return [String] an absolute path to a Kitchen global YAML file
      # @api private
      def default_global_config_file
        File.join(File.expand_path(ENV["HOME"]), ".kitchen", "config.yml")
      end

      # Generate a diganose Hash for a particular YAML file Hash. If an error
      # occurs when loading the data, then a failure hash will be inserted
      # into the `:raw_data` sub-hash.
      #
      # @param component [Symbol] a YAML source component
      # @param file [String] the absolute path to a file which is used for
      #   reporting (default: `nil`)
      # @return [Hash] a hash data structure
      # @api private
      def diagnose_component(component, file = nil)
        return if file && !File.exist?(file)

        hash = begin
          send(component)
        rescue => e
          failure_hash(e, file)
        end

        { :filename => file, :raw_data => hash }
      end

      # Generates a Hash respresenting a failure, given an Exception object.
      #
      # @param e [Exception] an exception
      # @param file [String] the absolute path to a file (default: `nil`)
      # @return [Hash] a hash data structure
      # @api private
      def failure_hash(e, file = nil)
        result = {
          :error => {
            :exception => e.inspect,
            :message => e.message,
            :backtrace => e.backtrace
          }
        }
        result[:error][:raw_file] = IO.read(file) unless file.nil?
        result
      end

      # Destructively modify an object containing one or more hashes so that
      # the resulting formatted data can be consumed upstream.
      #
      # @param obj [Object] an object
      # @return [Object] an object
      # @api private
      def normalize(obj)
        if obj.is_a?(Hash)
          obj.inject(Hash.new) { |h, (k, v)| normalize_hash(h, k, v); h }
        else
          obj
        end
      end

      # Normalizes certain keys in the root of a data hash to be a proper
      # sub-hash in all cases. Specifically handled are the following cases:
      #
      # * If the value for certain keys (`"driver"`, `"provisioner"`,
      #   `"busser"`) are set to `nil`, a new Hash will be put in its place.
      # * If the value for certain keys is a String, then the value is
      #   converted to a new Hash with a default key pointing to the original
      #   String.
      #
      # Given a hash:
      #
      #   { "driver" => nil }
      #
      # this method would return:
      #
      #   { "driver" => {} }
      #
      # Given a hash:
      #
      #   { :driver => "coolbeans" }
      #
      # this method would return:
      #
      #   { :name => { "driver" => "coolbeans" } }
      #
      #
      # @param hash [Hash] the Hash to normalize
      # @param key [Symbol] the key to normalize
      # @param value [Object] the value to normalize
      # @api private
      def normalize_hash(hash, key, value)
        case key
        when "driver", "provisioner", "busser"
          hash[key] = if value.nil?
            Hash.new
          elsif value.is_a?(String)
            default_key = key == "busser" ? "version" : "name"
            { default_key => value }
          else
            normalize(value)
          end
        else
          hash[key] = normalize(value)
        end
      end

      # Parses a YAML string and returns a Hash.
      #
      # @param string [String] a yaml document as a string
      # @param file_name [String] an absolute path to the file represented as
      #   the passed in string, used for error reporting
      # @return [Hash] a hash
      # @raise [UserError] if the string document cannot be parsed
      # @api private
      def parse_yaml_string(string, file_name)
        return Hash.new if string.nil? || string.empty?

        result = SafeYAML.load(string) || Hash.new
        unless result.is_a?(Hash)
          raise UserError, "Error parsing #{file_name} as YAML " \
            "(Result of parse was not a Hash, but was a #{result.class}).\n" \
            "Please run `kitchen diagnose --no-instances --loader' to help " \
            "debug your issue."
        end
        result
      rescue SyntaxError, Psych::SyntaxError
        raise UserError, "Error parsing #{file_name} as YAML.\n" \
          "Please run `kitchen diagnose --no-instances --loader' to help " \
          "debug your issue."
      end
    end
  end
end

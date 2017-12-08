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

require "yaml"

module Kitchen
  # Exception class for any exceptions raised when reading and parsing a state
  # file from disk
  class StateFileLoadError < StandardError; end

  # State persistence manager for instances between actions and invocations.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class StateFile
    # Constructs an new instance taking the kitchen root and instance name.
    #
    # @param kitchen_root [String] path to the Kitchen project's root directory
    # @param name [String] name of the instance representing this state
    def initialize(kitchen_root, name)
      @file_name = File.expand_path(
        File.join(kitchen_root, ".kitchen", "#{name}.yml")
      )
    end

    # Reads and loads an instance's state into a Hash data structure which is
    # returned.
    #
    # @return [Hash] a hash representation of an instance's state
    # @raise [StateFileLoadError] if there is a problem loading the state file
    #   from disk and loading it into a Hash
    def read
      if File.exist?(file_name) && !File.zero?(file_name)
        Util.symbolized_hash(deserialize_string(read_file))
      else
        {}
      end
    end

    # Serializes the state hash and writes a state file to disk.
    #
    # @param state [Hash] the current state of the instance
    def write(state)
      dir = File.dirname(file_name)
      serialized_string = serialize_hash(Util.stringified_hash(state))

      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      File.open(file_name, "wb") { |f| f.write(serialized_string) }
    end

    # Destroys a state file on disk if it exists.
    def destroy
      FileUtils.rm_f(file_name) if File.exist?(file_name)
    end

    # Returns a Hash of configuration and other useful diagnostic information.
    #
    # @return [Hash] a diagnostic hash
    def diagnose
      raw = read
      result = {}
      raw.keys.sort.each { |k| result[k] = raw[k] }
      result
    end

    private

    # @return [String] absolute path to the yaml state file on disk
    # @api private
    attr_reader :file_name

    # @return [String] a string representation of the yaml state file
    # @api private
    def read_file
      IO.read(file_name)
    end

    # Parses a YAML string and returns a Hash.
    #
    # @param string [String] a yaml document as a string
    # @return [Hash] a hash
    # @raise [StateFileLoadError] if the string document cannot be parsed
    # @api private
    def deserialize_string(string)
      YAML.safe_load(string)
    rescue SyntaxError, Psych::SyntaxError, Psych::DisallowedClass => ex
      raise StateFileLoadError, "Error parsing #{file_name} (#{ex.message})"
    end

    # Serializes a Hash into a YAML string.
    #
    # @param hash [Hash] a hash
    # @return [String] a yaml document as a string
    # @api private
    def serialize_hash(hash)
      ::YAML.dump(hash)
    end
  end
end

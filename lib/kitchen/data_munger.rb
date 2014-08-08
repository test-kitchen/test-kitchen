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

require "vendor/hash_recursive_merge"

module Kitchen

  # Class to handle recursive merging of configuration between platforms,
  # suites, and common data.
  #
  # This object will mutate the data Hash passed into its constructor and so
  # should not be reused or shared across threads.
  #
  # If you are squeamish or faint of heart, then you might want to skip this
  # class. Just remember, you were warned. And if you made it this far, be
  # sure to tweet at @fnichol and let him know your fear factor level.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class DataMunger

    # Constructs a new DataMunger object.
    #
    # @param data [Hash] the incoming user data hash
    # @param kitchen_config [Hash] the incoming Test Kitchen-provided
    #   configuration hash
    def initialize(data, kitchen_config = {})
      @data = data
      @kitchen_config = kitchen_config
      convert_legacy_driver_format!
      convert_legacy_chef_paths_format!
      convert_legacy_require_chef_omnibus_format!
      move_chef_data_to_provisioner!
    end

    # Generate a new Hash of configuration data that can be used to construct
    # a new Busser object.
    #
    # @param suite [String] a suite name
    # @param platform [String] a platform name
    # @return [Hash] a new configuration Hash that can be used to construct a
    #   new Busser
    def busser_data_for(suite, platform)
      merged_data_for(:busser, suite, platform, :version).tap do |bdata|
        set_kitchen_config_at!(bdata, :kitchen_root)
        set_kitchen_config_at!(bdata, :test_base_path)
        set_kitchen_config_at!(bdata, :log_level)
      end
    end

    # Generate a new Hash of configuration data that can be used to construct
    # a new Driver object.
    #
    # @param suite [String] a suite name
    # @param platform [String] a platform name
    # @return [Hash] a new configuration Hash that can be used to construct a
    #   new Driver
    def driver_data_for(suite, platform)
      merged_data_for(:driver, suite, platform).tap do |ddata|
        set_kitchen_config_at!(ddata, :kitchen_root)
        set_kitchen_config_at!(ddata, :test_base_path)
        set_kitchen_config_at!(ddata, :log_level)
      end
    end

    # Returns an Array of platform Hashes.
    #
    # @return [Array<Hash>] an Array of Hashes
    def platform_data
      data.fetch(:platforms, [])
    end

    # Generate a new Hash of configuration data that can be used to construct
    # a new Transport object.
    #
    # @param suite [String] a suite name
    # @param platform [String] a platform name
    # @return [Hash] a new configuration Hash that can be used to construct a
    #   new Transport
    def transport_data_for(suite, platform)
      merged_data_for(:transport, suite, platform).tap do |tdata|
        set_kitchen_config_at!(tdata, :kitchen_root)
        set_kitchen_config_at!(tdata, :test_base_path)
        set_kitchen_config_at!(tdata, :log_level)
        combine_arrays!(tdata, :run_list, :platform, :suite)
      end
    end

    # Generate a new Hash of configuration data that can be used to construct
    # a new Provisioner object.
    #
    # @param suite [String] a suite name
    # @param platform [String] a platform name
    # @return [Hash] a new configuration Hash that can be used to construct a
    #   new Provisioner
    def provisioner_data_for(suite, platform)
      merged_data_for(:provisioner, suite, platform).tap do |pdata|
        set_kitchen_config_at!(pdata, :kitchen_root)
        set_kitchen_config_at!(pdata, :test_base_path)
        set_kitchen_config_at!(pdata, :log_level)
        combine_arrays!(pdata, :run_list, :platform, :suite)
      end
    end

    # Returns an Array of suite Hashes.
    #
    # @return [Array<Hash>] an Array of Hashes
    def suite_data
      data.fetch(:suites, [])
    end

    private

    # @return [Hash] the user data hash
    # @api private
    attr_reader :data

    # @return [Hash] the Test Kitchen-provided configuration hash
    # @api private
    attr_reader :kitchen_config

    def combine_arrays!(root, key, *namespaces)
      if root.key?(key)
        root[key] = namespaces.
          map { |namespace| root.fetch(key).fetch(namespace, []) }.flatten.
          compact
      end
    end

    # Destructively moves Chef-related paths out of a suite hash and into the
    # suite's provisioner sub-hash.
    #
    # This method converts the following:
    #
    #     {
    #       :suites => [
    #         {
    #           :name => "alpha",
    #           :nodes_path => "/a/b/c"
    #         },
    #         {
    #           :name => "beta",
    #           :roles_path => "/tmp/roles",
    #           :data_bags_path => "/bags"
    #         },
    #       ]
    #     }
    #
    # into the following:
    #
    #     {
    #       :suites => [
    #         {
    #           :name => "alpha",
    #           :provisioner => {
    #             :nodes_path => "/a/b/c"
    #           }
    #         },
    #         {
    #           :name => "beta",
    #           :provisioner => {
    #             :roles_path => "/tmp/roles",
    #             :data_bags_path => "/bags"
    #           }
    #         },
    #       ]
    #     }
    #
    # @deprecated The following Chef paths should no longer be created directly
    #   under a suite hash: [`data_path`, `data_bags_path`,
    #   `encrypted_data_bag_secret_key_path`, `environments_path`, `nodes_path`,
    #   `roles_path`]. Instead put these key/value pairs directly inside a
    #   `provisioner` hash.
    # @api private
    def convert_legacy_chef_paths_format!
      data.fetch(:suites, []).each do |suite|
        %w[
          data data_bags encrypted_data_bag_secret_key
          environments nodes roles
        ].each do |key|
          move_chef_data_to_provisioner_at!(suite, "#{key}_path".to_sym)
        end
      end
    end

    # Destructively moves old-style `:driver_plugin` and `:driver_config`
    # configuration hashes into the correct `:driver` hash.
    #
    # This method converts the following:
    #
    #   {
    #     :driver_plugin => "foo",
    #     :driver_config => { :one => "two" },
    #
    #     :platforms => [
    #       {
    #         :name => "ubuntu-12.04",
    #         :driver_plugin => "bar"
    #       }
    #     ],
    #
    #     :suites => [
    #       {
    #         :name => "alpha",
    #         :driver_plugin => "baz"
    #         :driver_config => { :three => "four" }
    #       }
    #     ]
    #   }
    #
    # into the following:
    #
    #   {
    #     :driver => {
    #       :name => "foo",
    #       :one => "two"
    #     }
    #
    #     :platforms => [
    #       {
    #         :name => "ubuntu-12.04",
    #         :driver => {
    #           :name => "bar"
    #         }
    #       }
    #     ],
    #
    #     :suites => [
    #       {
    #         :name => "alpha",
    #         :driver => {
    #           :name => "baz",
    #           :three => "four"
    #         }
    #       }
    #     ]
    #   }
    #
    # @deprecated The following configuration hashes should no longer be
    #   created in a `:platform`, `:suite`, or common location:
    #   [`:driver_plugin`, `:driver_config`]. Use a `:driver` hash block in
    #   their place.
    # @api private
    def convert_legacy_driver_format!
      convert_legacy_driver_format_at!(data)
      data.fetch(:platforms, []).each do |platform|
        convert_legacy_driver_format_at!(platform)
      end
      data.fetch(:suites, []).each do |suite|
        convert_legacy_driver_format_at!(suite)
      end
    end

    # Destructively moves old-style `:driver_plugin` and `:driver_config`
    # configuration hashes into the correct `:driver` in the first level depth
    # of a hash. This method has no knowledge of suites, platforms, or the
    # like, just a vanilla hash.
    #
    # @param root [Hash] a hash to use as the root of the conversion
    # @deprecated The following configuration hashes should no longer be
    #   created in a Test Kitche hash: [`:driver_plugin`, `:driver_config`].
    #   Use a `:driver` hash block in their place.
    # @api private
    def convert_legacy_driver_format_at!(root)
      if root.key?(:driver_config)
        ddata = root.fetch(:driver, Hash.new)
        ddata = { :name => ddata } if ddata.is_a?(String)
        root[:driver] = root.delete(:driver_config).rmerge(ddata)
      end

      if root.key?(:driver_plugin)
        ddata = root.fetch(:driver, Hash.new)
        ddata = { :name => ddata } if ddata.is_a?(String)
        root[:driver] = { :name => root.delete(:driver_plugin) }.rmerge(ddata)
      end
    end

    # Destructively moves a `:require_chef_omnibus` key/value pair from a
    # `:driver` hash block to a `:provisioner` hash block.
    #
    # This method converts the following:
    #
    #   {
    #     :driver => {
    #       :require_chef_omnibus => true
    #     }
    #
    #     :platforms => [
    #       {
    #         :name => "ubuntu-12.04",
    #         :driver => {
    #           :require_chef_omnibus => "10.8.2"
    #         }
    #       }
    #     ],
    #
    #     :suites => [
    #       {
    #         :name => "alpha",
    #         :driver => {
    #           :require_chef_omnibus => "11"
    #         }
    #       }
    #     ]
    #   }
    #
    # into the following:
    #
    #   {
    #     :provisioner => {
    #       :require_chef_omnibus => true
    #     }
    #
    #     :platforms => [
    #       {
    #         :name => "ubuntu-12.04",
    #         :provisioner => {
    #           :require_chef_omnibus => "10.8.2"
    #         }
    #       }
    #     ],
    #
    #     :suites => [
    #       {
    #         :name => "alpha",
    #         :provisioner => {
    #           :require_chef_omnibus => "11"
    #         }
    #       }
    #     ]
    #   }
    #
    # @deprecated The `:require_chef_omnibus` key/value pair should no longer
    #   be created inside a `:driver` hash block. Put it in a `:provisioner`
    #   hash block instead.
    # @api private
    def convert_legacy_require_chef_omnibus_format!
      convert_legacy_require_chef_omnibus_format_at!(data)
      data.fetch(:platforms, []).each do |platform|
        convert_legacy_require_chef_omnibus_format_at!(platform)
      end
      data.fetch(:suites, []).each do |suite|
        convert_legacy_require_chef_omnibus_format_at!(suite)
      end
    end

    # Destructively moves a `:require_chef_omnibus` key/value pair from a
    # `:driver` hash block to a `:provisioner` hash block in the first leve
    # depth of a hash. This method has no knowledge of suites, platforms, or
    # the like, just a vanilla haash.
    #
    # @param root [Hash] a hash to use as the root of the conversion
    # @deprecated The `:require_chef_omnibus` key/value pair should no longer
    #   be created inside a `:driver` hash block. Put it in a `:provisioner`
    #   hash block instead.
    # @api private
    def convert_legacy_require_chef_omnibus_format_at!(root)
      key = :require_chef_omnibus
      ddata = root.fetch(:driver, Hash.new)

      if ddata.is_a?(Hash) && ddata.key?(key)
        pdata = root.fetch(:provisioner, Hash.new)
        pdata = { :name => pdata } if pdata.is_a?(String)
        root[:provisioner] =
          { key => root.fetch(:driver).delete(key) }.rmerge(pdata)
      end
    end

    # Performs a prioritized recursive merge of several source Hashes and
    # returns a new merged Hash. For these data sub-hash structures, there are
    # 4 sources for configuration data:
    #
    # 1. defaults, provided by Test Kitchen code
    # 2. user-provided in the common root-level of the incoming data hash
    # 3. user-provided in a platform sub-hash
    # 4. user-provided in a suite sub-hash
    #
    # The merge order is 4 -> 3 -> 2 -> 1, meaning that the highest number in
    # the above list has merge precedence over any lower numbered source. Put
    # another way, a key/value pair in a suite sub-hash will be used over the
    # key/value pair in a platform sub-hash.
    #
    # @param key [Symbol] the data sub-hash(es) to merge
    # @param suite [String] a suite name
    # @param platform [String] a platform name
    # @param default_key [Symbol] the default key to use when normalizing the
    #   data sub-hashes (default: `:name`)
    # @return [Hash] a new merged Hash
    # @api private
    def merged_data_for(key, suite, platform, default_key = :name)
      ddata = normalized_default_data(key, default_key)
      cdata = normalized_common_data(key, default_key)
      pdata = normalized_platform_data(key, default_key, platform)
      sdata = normalized_suite_data(key, default_key, suite)

      ddata.rmerge(cdata.rmerge(pdata.rmerge(sdata)))
    end

    # Destructively moves key Chef configuration key/value pairs from being
    # directly under a suite or platform into a `:provisioner` sub-hash.
    #
    # There are two key Chef configuration key/value pairs:
    #
    # 1. `:attributes`
    # 2. `:run_list`
    #
    # This method converts the following:
    #
    #   {
    #     :platforms => [
    #       {
    #         :name => "ubuntu-12.04",
    #         :attributes => { :one => "two" },
    #         :run_list => ["alpha", "bravo"]
    #       }
    #     ],
    #
    #     :suites => [
    #       {
    #         :name => "alpha",
    #         :attributes => { :three => "four" },
    #         :run_list => ["charlie", "delta"]
    #       }
    #     ]
    #   }
    #
    # into the following:
    #
    #   {
    #     :platforms => [
    #       {
    #         :name => "ubuntu-12.04",
    #         :provisioner => {
    #           :attributes => { :one => "two" },
    #           :run_list => ["alpha", "bravo"]
    #         }
    #       }
    #     ],
    #
    #     :suites => [
    #       {
    #         :name => "alpha",
    #         :provisioner => {
    #           :attributes => { :three => "four" },
    #           :run_list => ["charlie", "delta"]
    #         }
    #       }
    #     ]
    #   }
    #
    # @api private
    def move_chef_data_to_provisioner!
      data.fetch(:suites, []).each do |suite|
        move_chef_data_to_provisioner_at!(suite, :attributes)
        move_chef_data_to_provisioner_at!(suite, :run_list)
      end

      data.fetch(:platforms, []).each do |platform|
        move_chef_data_to_provisioner_at!(platform, :attributes)
        move_chef_data_to_provisioner_at!(platform, :run_list)
      end
    end

    # Destructively moves key Chef configuration key/value pairs from being
    # directly under a hash into a `:provisioner` sub-hash block. This method
    # has no knowledge of suites, platforms, or the like, just a vanilla hash.
    #
    # @param root [Hash] a hash to use as the root of the conversion
    # @param key [Symbol] a key in the root hash to move into a `:provisioner`
    #   sub-hash block
    # @api private
    def move_chef_data_to_provisioner_at!(root, key)
      if root.key?(key)
        pdata = root.fetch(:provisioner, Hash.new)
        pdata = { :name => pdata } if pdata.is_a?(String)
        if !root.fetch(key, nil).nil?
          root[:provisioner] = pdata.rmerge(key => root.delete(key))
        end
      end
    end

    # Vicious hack to allow for Array-appending merge semantics. This method
    # takes an array value and transforms it into a hash with a bucket name
    # containing the original Array. This way semantic Hash merging will do
    # its thing and another process can collapse the hash into a flat array
    # afterwards, given a strategy (like use the array segmenet from one
    # bucket first, then another one second). To anyone who made it this far,
    # Fletcher appologizes.
    #
    # @param root [Hash] a hash to use as the root of the conversion
    # @param key [Symbol] a key in the root hash that, if exists, has its
    #   value transformed into a sub-hash
    # @param bucket [Symbol] a key to use for the sub-hash
    # @api private
    def namespace_array!(root, key, bucket)
      root[key] = { bucket => root.fetch(key) } if root.key?(key)
    end

    # Normalizes a specific key in the root of the data hash to be a proper
    # sub-hash in all cases. Specifically handled are the following cases:
    #
    # * If the value for a key is set to `nil`, a new Hash will be put in
    #   its place.
    # * If the value is a String, then convert the value to a new Hash with
    #   a default key pointing to the original String
    #
    # Given a hash:
    #
    #   { :driver => nil }
    #
    # this method (`normalized_common_data(:driver, :name)`) would return:
    #
    #   {}
    #
    # Given a hash:
    #
    #   { :driver => "coolbeans" }
    #
    # this method (`normalized_common_data(:driver, :name)`) would return:
    #
    #   { :name => "coolbeans" }
    #
    # @param key [Symbol] the value to normalize
    # @param default_key [Symbol] the implicit default key if a String value
    #   is given
    # @return [Hash] a shallow Hash copy of the original if not modified, or a
    #   new Hash otherwise
    # @api private
    def normalized_common_data(key, default_key)
      cdata = data.fetch(key, Hash.new)
      cdata = cdata.nil? ? Hash.new : cdata.dup
      cdata = { default_key => cdata } if cdata.is_a?(String)
      cdata
    end

    # Normalizes a specific key in the `:defaults` data sub-hash to be a proper
    # sub-hash in all cases. Specifically handled are the following cases:
    #
    # * If the value for a key is not set, a new Hash will be put in its place
    # * If the value is a String, then convert the value to a new Hash with
    #   a default key pointing to the original String
    #
    # Given a hash:
    #
    #   {
    #     :defaults => {}
    #   }
    #
    # this method (`normalized_default_data(:driver, :name)`) would return:
    #
    #   {}
    #
    # Given a hash:
    #
    #   {
    #     :defaults => {
    #       :driver => "coolbeans"
    #     }
    #   }
    #
    # this method (`normalized_default_data(:driver, :name)`) would return:
    #
    #   { :name => "coolbeans" }
    #
    # @param key [Symbol] the value to normalize
    # @param default_key [Symbol] the implicit default key if a String value
    #   is given
    # @return [Hash] a shallow Hash copy of the original if not modified, or a
    #   new Hash otherwise
    # @api private
    def normalized_default_data(key, default_key)
      ddata = kitchen_config.fetch(:defaults, Hash.new).fetch(key, Hash.new).dup
      ddata = { default_key => ddata } if ddata.is_a?(String)
      ddata
    end

    # Normalizes a specific key in a platform hash data sub-hash to be a proper
    # sub-hash in all cases. Specifically handled are the following cases:
    #
    # * If the value for a key is set to `nil`, a new Hash will be put in
    #   its place.
    # * If the value is a String, then convert the value to a new Hash with
    #   a default key pointing to the original String
    #
    # Given a hash:
    #
    #   {
    #     :platforms => [
    #       {
    #         :name => "alpha",
    #         :driver => nil
    #       }
    #     ]
    #   }
    #
    # this method (`normalized_platform_data(:driver, :name, "alpha)`) would
    # return:
    #
    #   {}
    #
    # Given a hash:
    #
    #   {
    #     :platforms => [
    #       {
    #         :name => "alpha",
    #         :driver => "coolbeans"
    #       }
    #     ]
    #   }
    #
    # this method (`normalized_common_data(:driver, :name, "alpha")`) would
    # return:
    #
    #   { :name => "coolbeans" }
    #
    # @param key [Symbol] the value to normalize
    # @param default_key [Symbol] the implicit default key if a String value
    #   is given
    # @param platform [String] name of a platform
    # @return [Hash] a shallow Hash copy of the original if not modified, or a
    #   new Hash otherwise
    # @api private
    def normalized_platform_data(key, default_key, platform)
      pdata = platform_data_for(platform).fetch(key, Hash.new)
      pdata = pdata.nil? ? Hash.new : pdata.dup
      pdata = { default_key => pdata } if pdata.is_a?(String)
      namespace_array!(pdata, :run_list, :platform)
      pdata
    end

    # Normalizes a specific key in a suite hash data sub-hash to be a proper
    # sub-hash in all cases. Specifically handled are the following cases:
    #
    # * If the value for a key is set to `nil`, a new Hash will be put in
    #   its place.
    # * If the value is a String, then convert the value to a new Hash with
    #   a default key pointing to the original String
    #
    # Given a hash:
    #
    #   {
    #     :suites => [
    #       {
    #         :name => "full",
    #         :driver => nil
    #       }
    #     ]
    #   }
    #
    # this method (`normalized_platform_data(:driver, :name, "full)`) would
    # return:
    #
    #   {}
    #
    # Given a hash:
    #
    #   {
    #     :suites => [
    #       {
    #         :name => "full",
    #         :driver => "coolbeans"
    #       }
    #     ]
    #   }
    #
    # this method (`normalized_common_data(:driver, :name, "full")`) would
    # return:
    #
    #   { :name => "coolbeans" }
    #
    # @param key [Symbol] the value to normalize
    # @param default_key [Symbol] the implicit default key if a String value
    #   is given
    # @param suite [String] name of a suite
    # @return [Hash] a shallow Hash copy of the original if not modified, or a
    #   new Hash otherwise
    # @api private
    def normalized_suite_data(key, default_key, suite)
      sdata = suite_data_for(suite).fetch(key, Hash.new)
      sdata = sdata.nil? ? Hash.new : sdata.dup
      sdata = { default_key => sdata } if sdata.is_a?(String)
      namespace_array!(sdata, :run_list, :suite)
      sdata
    end

    # Returns the hash for a platform by name, or an empty Hash if none
    # could be found.
    #
    # @param name [String] name of a platform
    # @return [Hash] the configuration hash for the platform, or an empty
    #   Hash if not found
    # @api private
    def platform_data_for(name)
      data.fetch(:platforms, Hash.new).find(-> { Hash.new }) do |platform|
        platform.fetch(:name, nil) == name
      end
    end

    # Destructively sets a base kitchen config key/value pair at the root of
    # the given hash. If the key is present in the given Hash, it is deleted
    # and will not be used. If the key is found in the `kitchen_config` hash
    # (default values), then its value will be used and set. Finally, if
    # the key is found in `:kitchen` data sub-hash, then its value will be used
    # and set.
    #
    # @param root [Hash] a hash to use as the root of the conversion
    # @param key [Symbol] the key to search for
    # @api private
    def set_kitchen_config_at!(root, key)
      kdata = data.fetch(:kitchen, Hash.new)

      root.delete(key) if root.key?(key)
      root[key] = kitchen_config.fetch(key) if kitchen_config.key?(key)
      root[key] = kdata.fetch(key) if kdata.key?(key)
    end

    # Returns the hash for a suite by name, or an empty Hash if none
    # could be found.
    #
    # @param name [String] name of a suite
    # @return [Hash] the configuration hash for the suite, or an empty
    #   Hash if not found
    # @api private
    def suite_data_for(name)
      data.fetch(:suites, Hash.new).find(-> { Hash.new }) do |suite|
        suite.fetch(:name, nil) == name
      end
    end
  end
end

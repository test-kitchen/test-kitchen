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

require 'vendor/hash_recursive_merge'

module Kitchen

  # Class to handle recursive merging of configuration between platforms,
  # suites, and common data.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class DataMunger

    def initialize(data, kitchen_config = {})
      @data = data
      @kitchen_config = kitchen_config
      convert_legacy_driver_format!
      convert_legacy_chef_paths_format!
      convert_legacy_require_chef_omnibus_format!
      move_chef_data_to_provisioner!
    end

    def busser_data_for(suite, platform)
      data_for(suite, platform)[:busser]
    end

    def data_for(suite, platform)
      suite_data = base_data[:suites].select { |s| s[:name] == suite.name }.first
      platform_data = base_data[:platforms].select { |p| p[:name] == platform.name }.first
      configs = normalized_configs(suite_data, platform_data) + base_data.configs
      Cheffish::MergedConfig.new(*configs)
    end

    def platform_data
      base_data[:platforms].map { |p| data_for_platform(p) }
    end

    def provisioner_data_for(suite, platform)
      config = data_for(suite, platform)[:provisioner]
      config = Cheffish::MergedConfig.new(config) if !config.respond_to?(:configs)
      config.merge_arrays :run_list, :platform, :suite
      config
    end

    def suite_data
      base_data[:suites].map { |s| data_for_suite(s) }
    end

    private

    attr_reader :data, :kitchen_config

    def convert_legacy_chef_paths_format!
      data.fetch(:suites, []).each do |suite|
        %w{data data_bags encrypted_data_bag_secret_key
          environments nodes roles}.each do |key|
            move_chef_data_to_provisioner_at!(suite, "#{key}_path".to_sym)
        end
      end
    end

    def convert_legacy_driver_format!
      convert_legacy_driver_format_at!(data)
      data.fetch(:platforms, []).each do |platform|
        convert_legacy_driver_format_at!(platform)
      end
      data.fetch(:suites, []).each do |suite|
        convert_legacy_driver_format_at!(suite)
      end
    end

    def convert_legacy_driver_format_at!(root)
      if root.has_key?(:driver_config)
        ddata = root.fetch(:driver, Hash.new)
        ddata = { :name => ddata } if ddata.is_a?(String)
        root[:driver] = root.delete(:driver_config).rmerge(ddata)
      end

      if root.has_key?(:driver_plugin)
        ddata = root.fetch(:driver, Hash.new)
        ddata = { :name => ddata } if ddata.is_a?(String)
        root[:driver] = { :name => root.delete(:driver_plugin) }.rmerge(ddata)
      end
    end

    def convert_legacy_require_chef_omnibus_format!
      convert_legacy_require_chef_omnibus_format_at!(data)
      data.fetch(:platforms, []).each do |platform|
        convert_legacy_require_chef_omnibus_format_at!(platform)
      end
      data.fetch(:suites, []).each do |suite|
        convert_legacy_require_chef_omnibus_format_at!(suite)
      end
    end

    def convert_legacy_require_chef_omnibus_format_at!(root)
      key = :require_chef_omnibus
      ddata = root.fetch(:driver, Hash.new)

      if ddata.is_a?(Hash) && ddata.has_key?(key)
        pdata = root.fetch(:provisioner, Hash.new)
        pdata = { :name => pdata } if pdata.is_a?(String)
        root[:provisioner] =
          { key => root.fetch(:driver).delete(key) }.rmerge(pdata)
      end
    end

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

    def move_chef_data_to_provisioner_at!(root, key)
      if root.has_key?(key)
        pdata = root.fetch(:provisioner, Hash.new)
        pdata = { :name => pdata } if pdata.is_a?(String)
        if ! root.fetch(key, nil).nil?
          root[:provisioner] = pdata.rmerge({ key => root.delete(key) })
        end
      end
    end

    def namespace_array!(root, key, bucket)
      root[key] = { bucket => root.fetch(key) } if root.has_key?(key)
    end

    def base_data
      @base_data ||= begin
        configs = normalized_configs(
          data,
          data[:kitchen],
          Cheffish.profiled_config(Chef::Config),
          kitchen_config.fetch(:defaults)
        )
        merged = Cheffish::MergedConfig.new(*configs)
        merged.merge_arrays :suites, :platforms, :run_list
        merged
      end
    end

    def data_for_suite(suite_data)
      configs = normalized_configs(suite_data) + base_data.configs
      Cheffish::MergedConfig.new(*configs)
    end

    def data_for_platform(platform_data)
      configs = normalized_configs(platform_data) + base_data.configs
      Cheffish::MergedConfig.new(*configs)
    end

    def normalized_configs(*configs)
      configs = configs.select { |c| !c.nil? }
      configs = configs.collect_concat { |c| c.respond_to?(:configs) ? c.configs : c }
      configs.map { |c| normalize_kitchen_data(c) }
    end

    def normalize_kitchen_data(data)
      result = data.dup
      # driver: name
      # driver_options: hash
      if result[:driver] && result[:driver].respond_to?(:keys)
        result[:driver_options] = result[:driver]
        result[:driver] = result[:driver][:name] if result[:driver][:name]
      end
      # busser: hash
      if result[:busser] && result[:busser].is_a?(Hash)
        result[:busser] = { :version => result[:busser] }
      end
      # provisioner: hash
      if result[:provisioner] && result[:provisioner].is_a?(Hash)
        result[:provisioner] = { :version => result[:provisioner] }
      end
      # run_list
      result
    end
  end
end

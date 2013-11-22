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

require 'vendor/hash_recursive_merge'

module Kitchen

  # Class to handle recursive merging of configuration between platforms,
  # suites, and common data.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class DataMunger

    def initialize(data)
      @data = data
      convert_legacy_driver_format!
    end

    def driver(suite, platform)
      merged_data_for(:driver, suite, platform)
    end

    def provisioner(suite, platform)
      merged_data_for(:provisioner, suite, platform)
    end

    def busser(suite, platform)
      merged_data_for(:busser, suite, platform, :version)
    end

    private

    attr_reader :data

    def merged_data_for(key, suite, platform, default_key = :name)
      cdata = data.fetch(key, Hash.new)
      cdata = { default_key => cdata } if cdata.is_a?(String)
      pdata = platform_data(platform).fetch(key, Hash.new)
      pdata = { default_key => pdata } if pdata.is_a?(String)
      sdata = suite_data(suite).fetch(key, Hash.new)
      sdata = { default_key => sdata } if sdata.is_a?(String)

      cdata.rmerge(pdata.rmerge(sdata))
    end

    def platform_data(name)
      data.fetch(:platforms, Hash.new).find(lambda { Hash.new }) do |platform|
        platform.fetch(:name, nil) == name
      end
    end

    def suite_data(name)
      data.fetch(:suites, Hash.new).find(lambda { Hash.new }) do |suite|
        suite.fetch(:name, nil) == name
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
      if !root.has_key?(:driver)
        if root[:driver_config]
          root[:driver] = root.fetch(:driver, Hash.new).
            rmerge(root.delete(:driver_config))
        end

        if root[:driver_plugin]
          root[:driver] = root.fetch(:driver, Hash.new).
            rmerge({ :name => root.delete(:driver_plugin) })
        end
      end
    end
  end
end

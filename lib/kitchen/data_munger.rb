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
    end

    def driver(suite, platform)
      cdata = data.fetch(:driver, Hash.new)
      cdata = { :name => cdata } if cdata.is_a?(String)
      pdata = platform_data(platform).fetch(:driver, Hash.new)
      pdata = { :name => pdata } if pdata.is_a?(String)
      sdata = suite_data(suite).fetch(:driver, Hash.new)
      sdata = { :name => sdata } if sdata.is_a?(String)

      cdata.rmerge(pdata.rmerge(sdata))
    end

    def provisioner(suite, platform)
      cdata = data.fetch(:provisioner, Hash.new)
      cdata = { :name => cdata } if cdata.is_a?(String)
      pdata = platform_data(platform).fetch(:provisioner, Hash.new)
      pdata = { :name => pdata } if pdata.is_a?(String)
      sdata = suite_data(suite).fetch(:provisioner, Hash.new)
      sdata = { :name => sdata } if sdata.is_a?(String)

      cdata.rmerge(pdata.rmerge(sdata))
    end

    def busser(suite, platform)
      cdata = data.fetch(:busser, Hash.new)
      cdata = { :version => cdata } if cdata.is_a?(String)
      pdata = platform_data(platform, :version).fetch(:busser, Hash.new)
      pdata = { :version => pdata } if pdata.is_a?(String)
      sdata = suite_data(suite, :version).fetch(:busser, Hash.new)
      sdata = { :version => sdata } if sdata.is_a?(String)

      cdata.rmerge(pdata.rmerge(sdata))
    end

    private

    attr_reader :data

    def platform_data(name, default_key = :name)
      data.fetch(:platforms, Hash.new).find(lambda { Hash.new }) do |platform|
        platform.fetch(default_key, nil) == name
      end
    end

    def suite_data(name, default_key = :name)
      data.fetch(:suites, Hash.new).find(lambda { Hash.new }) do |suite|
        suite.fetch(default_key, nil) == name
      end
    end
  end
end

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

  # Base configuration class for Kitchen. This class exposes configuration such
  # as the location of the Kitchen config file, instances, log_levels, etc.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Config

    attr_reader :kitchen_root
    attr_reader :log_root
    attr_reader :test_base_path
    attr_reader :loader
    attr_reader :log_level

    # Creates a new configuration.
    #
    # @param [Hash] options configuration
    # @option options [#read] :loader
    # @option options [String] :kitchen_root
    # @option options [String] :log_root
    # @option options [String] :test_base_path
    # @option options [Symbol] :log_level
    def initialize(options = {})
      @loader         = options.fetch(:loader) { Kitchen::Loader::YAML.new }
      @kitchen_root   = options.fetch(:kitchen_root) { Dir.pwd }
      @log_level      = options.fetch(:log_level) { Kitchen::DEFAULT_LOG_LEVEL }
      @log_root       = options.fetch(:log_root) do
        File.join(@kitchen_root, Kitchen::DEFAULT_LOG_DIR)
      end
      @test_base_path = options.fetch(:test_base_path) do
        File.join(@kitchen_root, Kitchen::DEFAULT_TEST_DIR)
      end
    end

    # @return [Array<Platform>] all defined platforms which will be used in
    #   convergence integration
    def platforms
      @platforms ||= Collection.new(
        data.platform_data.map { |pdata| Platform.new(pdata) })
    end

    # @return [Array<Suite>] all defined suites which will be used in
    #   convergence integration
    def suites
      @suites ||= Collection.new(
        data.suite_data.map { |sdata| Suite.new(sdata) })
    end

    # @return [Array<Instance>] all instances, resulting from all platform and
    #   suite combinations
    def instances
      @instances ||= build_instances
    end

    private

    def kitchen_config
      @kitchen_config ||= {
        :kitchen_root => @kitchen_root,
        :test_base_path => @test_base_path,
        :defaults => {
          :driver => Driver::DEFAULT_PLUGIN,
          :provisioner => Driver::DEFAULT_PLUGIN
        }
      }
    end

    def data
      @data ||= DataMunger.new(loader.read, kitchen_config)
    end

    def instance_name(suite, platform)
      Instance.name_for(suite, platform)
    end

    def build_instances
      filtered = suites.product(platforms).select do |suite, platform|
        if !suite.includes.empty?
          suite.includes.include?(platform.name)
        elsif !suite.excludes.empty?
          !suite.excludes.include?(platform.name)
        else
          true
        end
      end

      instances = filtered.map.with_index do |(suite, platform), index|
        new_instance(suite, platform, index)
      end

      Collection.new(instances)
    end

    def new_instance(suite, platform, index)
      Instance.new(
        :suite => suite,
        :platform => platform,
        :driver => new_driver(suite, platform),
        :provisioner => new_provisioner(suite, platform),
        :busser => new_busser(suite, platform),
        :state_file => new_state_file(suite, platform),
        :logger => new_logger(suite, platform, index)
      )
    end

    def new_driver(suite, platform)
      ddata = data.driver_data_for(suite, platform)
      Driver.for_plugin(ddata[:name], ddata)
    end

    def new_provisioner(suite, platform)
      pdata = data.provisioner_data_for(suite, platform)
      Provisioner.for_plugin(pdata[:name], pdata)
    end

    def new_busser(suite, platform)
      bdata = data.busser_data_for(suite, platform)
      Busser.new(suite.name, bdata)
    end

    def new_state_file(suite, platform)
      StateFile.new(kitchen_root, instance_name(suite, platform))
    end

    def new_logger(suite, platform, index)
      name = instance_name(suite, platform)
      Logger.new(
        :stdout => STDOUT,
        :color => Color::COLORS[index % Color::COLORS.size].to_sym,
        :logdev => File.join(log_root, "#{name}.log"),
        :level => Util.to_logger_level(self.log_level),
        :progname => name
      )
    end
  end
end

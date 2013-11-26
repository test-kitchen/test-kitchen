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
    attr_accessor :log_level

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
      @log_root       = options.fetch(:log_root) { default_log_root }
      @test_base_path = options.fetch(:test_base_path) { default_test_base_path }
    end

    # @return [Array<Instance>] all instances, resulting from all platform and
    #   suite combinations
    def instances
      @instances ||= Collection.new(build_instances)
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

    private

    def build_instances
      filter_instances.map.with_index do |(suite, platform), index|
        new_instance(suite, platform, index)
      end
    end

    def data
      @data ||= DataMunger.new(loader.read, kitchen_config)
    end

    def default_log_root
      File.join(kitchen_root, Kitchen::DEFAULT_LOG_DIR)
    end

    def default_test_base_path
      File.join(kitchen_root, Kitchen::DEFAULT_TEST_DIR)
    end

    def filter_instances
      suites.product(platforms).select do |suite, platform|
        if !suite.includes.empty?
          suite.includes.include?(platform.name)
        elsif !suite.excludes.empty?
          !suite.excludes.include?(platform.name)
        else
          true
        end
      end
    end

    def instance_name(suite, platform)
      Instance.name_for(suite, platform)
    end

    def kitchen_config
      @kitchen_config ||= {
        :defaults => {
          :driver       => Driver::DEFAULT_PLUGIN,
          :provisioner  => Provisioner::DEFAULT_PLUGIN
        },
        :kitchen_root   => kitchen_root,
        :test_base_path => test_base_path,
        :log_level      => log_level,
      }
    end

    def new_busser(suite, platform)
      bdata = data.busser_data_for(suite.name, platform.name)
      Busser.new(suite.name, bdata)
    end

    def new_driver(suite, platform)
      ddata = data.driver_data_for(suite.name, platform.name)
      Driver.for_plugin(ddata[:name], ddata)
    end

    def new_instance(suite, platform, index)
      Instance.new(
        :busser       => new_busser(suite, platform),
        :driver       => new_driver(suite, platform),
        :logger       => new_logger(suite, platform, index),
        :suite        => suite,
        :platform     => platform,
        :provisioner  => new_provisioner(suite, platform),
        :state_file   => new_state_file(suite, platform)
      )
    end

    def new_logger(suite, platform, index)
      name = instance_name(suite, platform)
      Logger.new(
        :stdout   => STDOUT,
        :color    => Color::COLORS[index % Color::COLORS.size].to_sym,
        :logdev   => File.join(log_root, "#{name}.log"),
        :level    => Util.to_logger_level(self.log_level),
        :progname => name
      )
    end

    def new_provisioner(suite, platform)
      pdata = data.provisioner_data_for(suite.name, platform.name)
      Provisioner.for_plugin(pdata[:name], pdata)
    end

    def new_state_file(suite, platform)
      StateFile.new(kitchen_root, instance_name(suite, platform))
    end
  end
end

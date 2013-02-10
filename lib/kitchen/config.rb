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

require 'celluloid'
require 'erb'
require 'vendor/hash_recursive_merge'
require 'yaml'

module Kitchen

  # Base configuration class for Kitchen. This class exposes configuration such
  # as the location of the Kitchen YAML file, instances, log_levels, etc.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Config

    attr_writer :yaml_file
    attr_writer :platforms
    attr_writer :suites
    attr_writer :log_level
    attr_writer :supervised
    attr_writer :test_base_path

    # Default path to the Kitchen YAML file
    DEFAULT_YAML_FILE = File.join(Dir.pwd, '.kitchen.yml').freeze

    # Default driver plugin to use
    DEFAULT_DRIVER_PLUGIN = "dummy".freeze

    # Default base path which may contain `data_bags/` directories
    DEFAULT_TEST_BASE_PATH = File.join(Dir.pwd, 'test/integration').freeze

    # Creates a new configuration.
    #
    # @param yaml_file [String] optional path to Kitchen YAML file
    def initialize(yaml_file = nil)
      @yaml_file = yaml_file
    end

    # @return [Array<Platform>] all defined platforms which will be used in
    #   convergence integration
    def platforms
      @platforms ||= Collection.new(
        Array(yaml[:platforms]).map { |hash| new_platform(hash) })
    end

    # @return [Array<Suite>] all defined suites which will be used in
    #   convergence integration
    def suites
      @suites ||= Collection.new(
        Array(yaml[:suites]).map { |hash| new_suite(hash) })
    end

    # @return [Array<Instance>] all instances, resulting from all platform and
    #   suite combinations
    def instances
      instances_array(load_instances)
    end

    # @return [String] path to the Kitchen YAML file
    def yaml_file
      @yaml_file ||= DEFAULT_YAML_FILE
    end

    # @return [Symbol] log level verbosity
    def log_level
      @log_level ||= begin
        ENV['KITCHEN_LOG'] && ENV['KITCHEN_LOG'].downcase.to_sym ||
          Kitchen::DEFAULT_LOG_LEVEL
      end
    end

    def supervised
      @supervised.nil? ? @supervised = true : @supervised
    end

    # @return [String] base path that may contain a common `data_bags/`
    #   directory or an instance's `data_bags/` directory
    def test_base_path
      @test_base_path ||= DEFAULT_TEST_BASE_PATH
    end

    private

    def load_instances
      return @instance_count if @instance_count && @instance_count > 0

      results = []
      suites.product(platforms).each_with_index do |arr, index|
        results << new_instance(arr[0], arr[1], index)
      end
      @instance_count = results.size
    end

    def instances_array(instance_count)
      results = []
      instance_count.times do |index|
        results << Celluloid::Actor["instance_#{index}".to_sym]
      end
      Collection.new(results)
    end

    def new_suite(hash)
      path_hash = {
        :data_bags_path => calculate_path("data_bags", hash[:name]),
        :roles_path     => calculate_path("roles", hash[:name]),
      }

      Suite.new(hash.rmerge(path_hash))
    end

    def new_platform(hash)
      Platform.new(hash)
    end

    def new_driver(hash)
      hash[:driver_config] ||= Hash.new
      hash[:driver_config][:kitchen_root] = kitchen_root

      Driver.for_plugin(hash[:driver_plugin], hash[:driver_config])
    end

    def new_instance(suite, platform, index)
      platform_hash = platform_driver_hash(platform.name)
      driver = new_driver(merge_driver_hash(platform_hash))
      actor_name = "instance_#{index}".to_sym
      opts = {
        :suite    => suite,
        :platform => platform,
        :driver   => driver,
        :logger   => new_instance_logger(index)
      }

      new_instance_supervised_or_not(actor_name, opts)
    end

    def new_instance_supervised_or_not(actor_name, opts)
      if supervised
        supervisor = Instance.supervise_as(actor_name, opts)
        actor = supervisor.actors.first
        Kitchen.logger.debug("Supervising #{actor.to_str} with #{supervisor}")
        actor
      else
        Celluloid::Actor[actor_name] = Instance.new(opts)
      end
    end

    def log_root
      File.expand_path(File.join(kitchen_root, ".kitchen", "logs"))
    end

    def platform_driver_hash(platform_name)
      h = yaml[:platforms].find { |p| p[:name] == platform_name } || Hash.new

      h.select { |key, value| [:driver_plugin, :driver_config].include?(key) }
    end

    def new_instance_logger(index)
      level = Util.to_logger_level(self.log_level)
      color = Color::COLORS[index % Color::COLORS.size].to_sym

      lambda do |name|
        logfile = File.join(log_root, "#{name}.log")

        Logger.new(:stdout => STDOUT, :color => color, :logdev => logfile,
          :level => level, :progname => name)
      end
    end

    def yaml
      @yaml ||= Util.symbolized_hash(
        YAML.load(yaml_contents).rmerge(local_yaml))
    end

    def yaml_contents
      ERB.new(IO.read(File.expand_path(yaml_file))).result
    end

    def local_yaml_file
      std = File.expand_path(yaml_file)
      std.sub(/(#{File.extname(std)})$/, '.local\1')
    end

    def local_yaml
      @local_yaml ||= begin
        if File.exists?(local_yaml_file)
          YAML.load(ERB.new(IO.read(local_yaml_file)).result)
        else
          Hash.new
        end
      end
    end

    def kitchen_root
      File.dirname(yaml_file)
    end

    def merge_driver_hash(driver_hash)
      default_driver_hash.rmerge(common_driver_hash.rmerge(driver_hash))
    end

    def calculate_path(path, suite_name)
      suite_path      = File.join(test_base_path, suite_name, path)
      common_path     = File.join(test_base_path, path)
      top_level_path  = File.join(Dir.pwd, path)

      if File.directory?(suite_path)
        suite_path
      elsif File.directory?(common_path)
        common_path
      elsif File.directory?(top_level_path)
        top_level_path
      else
        nil
      end
    end

    def default_driver_hash
      { :driver_plugin => DEFAULT_DRIVER_PLUGIN, :driver_config => {} }
    end

    def common_driver_hash
      yaml.select do |key, value|
        [:driver_plugin, :driver_config].include?(key)
      end
    end
  end
end

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

  # Base configuration class for Kitchen. This class exposes configuration such
  # as the location of the Kitchen config file, instances, log_levels, etc.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Config

    attr_accessor :kitchen_root
    attr_accessor :test_base_path
    attr_accessor :log_level
    attr_writer :platforms
    attr_writer :suites

    # Default driver plugin to use
    DEFAULT_DRIVER_PLUGIN = "dummy".freeze

    # Default provisioner to use
    DEFAULT_PROVISIONER = "chef_solo".freeze

    # Creates a new configuration.
    #
    # @param [Hash] options configuration
    # @option options [#read] :loader
    # @option options [String] :kitchen_root
    # @option options [String] :test_base_path
    # @option options [Symbol] :log_level
    def initialize(options = {})
      @loader         = options[:loader] || Kitchen::Loader::YAML.new
      @kitchen_root   = options[:kitchen_root] || Dir.pwd
      @test_base_path = options[:test_base_path] || default_test_base_path
      @log_level      = options[:log_level] || Kitchen::DEFAULT_LOG_LEVEL
    end

    # @return [Array<Platform>] all defined platforms which will be used in
    #   convergence integration
    def platforms
      @platforms ||= Collection.new(
        Array(data[:platforms]).map { |hash| new_platform(hash) })
    end

    # @return [Array<Suite>] all defined suites which will be used in
    #   convergence integration
    def suites
      @suites ||= Collection.new(
        Array(data[:suites]).map { |hash| new_suite(hash) })
    end

    # @return [Array<Instance>] all instances, resulting from all platform and
    #   suite combinations
    def instances
      @instances ||= build_instances
    end

    # Constant/global settings defined in the YAML
    def settings
      data[:settings] || {}
    end

    private

    def new_suite(hash)
      path_hash = {
        :data_path      => calculate_path(
          "data", hash[:name], hash[:data_path]),
        :data_bags_path => calculate_path(
          "data_bags", hash[:name], hash[:data_bags_path]),
        :environments_path  => calculate_path(
          "environments", hash[:name], hash[:environments_path]),
        :nodes_path     => calculate_path(
          "nodes", hash[:name], hash[:nodes_path]),
        :roles_path     => calculate_path(
          "roles", hash[:name], hash[:roles_path]),
      }

      Suite.new(hash.rmerge(path_hash))
    end

    def new_platform(hash)
      Platform.new(hash)
    end

    def new_driver(hash)
      hash[:driver_config] ||= Hash.new
      hash[:driver_config][:kitchen_root] = kitchen_root
      hash[:driver_config][:provisioner] = hash[:provisioner]

      Driver.for_plugin(hash[:driver_plugin], hash[:driver_config])
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
      platform_hash = platform_driver_hash(platform.name)
      platform_hash[:driver_config].rmerge!(Hash.new) # tmp
      driver = new_driver(merge_driver_hash(platform_hash))
      provisioner = Provisioner.for_plugin("dummy", {})
      state_file = StateFile.new(kitchen_root, Instance.name_for(suite, platform))
      busser = Busser.new(suite.name, {})

      instance = Instance.new(
        :suite    => suite,
        :platform => platform,
        :driver   => driver,
        :logger   => new_instance_logger(index),
        :state_file => state_file,
        :busser => busser
      )
      instance
    end

    def extend_suite(suite, provisioner)
      case provisioner.to_s.downcase
      when /^chef_/ then suite.dup.extend(Suite::Cheflike)
      when /^puppet_/ then suite.dup.extend(Suite::Puppetlike)
      else suite.dup
      end
    end

    def extend_platform(platform, provisioner)
      case provisioner.to_s.downcase
      when /^chef_/ then platform.dup.extend(Platform::Cheflike)
      else platform.dup
      end
    end

    def extend_instance(instance, provisioner)
      case provisioner.to_s.downcase
      when /^chef_/ then instance.extend(Instance::Cheflike)
      when /^puppet_/ then instance.extend(Instance::Puppetlike)
      else instance
      end
    end

    def log_root
      File.expand_path(File.join(kitchen_root, ".kitchen", "logs"))
    end

    def platform_driver_hash(platform_name)
      h = data[:platforms].find { |p| p[:name] == platform_name } || Hash.new
      h[:driver_config] ||= {}

      h.select do |key, value|
        [:driver_plugin, :driver_config, :provisioner].include?(key)
      end
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

    def data
      @data ||= @loader.read
    end

    def merge_driver_hash(driver_hash)
      default_driver_hash.rmerge(common_driver_hash.rmerge(driver_hash))
    end

    def calculate_path(path, suite_name, local_path)
      possibles = [].tap do |a|
        a.push(local_path) if local_path
        a.push(File.join(kitchen_root, local_path)) if local_path
        a.push(File.join(test_base_path, suite_name, path))
        a.push(File.join(test_base_path, path))
        a.push(File.join(Dir.pwd, path))
      end.compact

      possibles.find { |path| File.directory?(path) }
    end

    def default_driver_hash
      {
        :driver_plugin  => DEFAULT_DRIVER_PLUGIN,
        :driver_config  => {},
        :provisioner    => DEFAULT_PROVISIONER
      }
    end

    def common_driver_hash
      data.select do |key, value|
        [:driver_plugin, :driver_config, :provisioner].include?(key)
      end
    end

    def default_test_base_path
      File.join(kitchen_root, 'test/integration')
    end
  end
end

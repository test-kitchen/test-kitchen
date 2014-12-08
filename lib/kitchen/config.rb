# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, 2013, 2014, Fletcher Nichol
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
  # This object is a factory object, meaning that it is responsible for
  # consuming the desired testing configuration in and returning Ruby objects
  # which are used to perfom the work.
  #
  # Most internal objects are created with the expectation of being
  # *immutable*, meaning that internal state cannot be modified after creation.
  # Any data manipulation or thread-unsafe activity is performed in this object
  # so that the subsequently created objects (such as Instances, Platforms,
  # Drivers, etc.) can safely run in concurrent threads of execution. To
  # prevent the re-creation of duplicate objects, most created objects are
  # memoized. The consequence of this is that once the Instance Array has
  # been requested (with the `#instances` message), you will always be returned
  # the same Instance objects.
  #
  # @example fetching all instances
  #
  #   Kitchen::Config.new.instances
  #
  # @example fetching an instance by name
  #
  #   Kitchen::Config.new.instances.get("default-ubuntu-12.04")
  #
  # @example fetching all instances matching a regular expression
  #
  #   Kitchen::Config.new.instances.get_all(/ubuntu/)
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Config

    # @return [String] the absolute path to the root of a Test Kitchen project
    # @api private
    attr_reader :kitchen_root

    # @return [String] the absolute path to the directory into which all Test
    #   Kitchen log files will be written
    # @api private
    attr_reader :log_root

    # @return [String] the absolute path to the directory containing test
    #   suites and other testing-related file and directories
    # @api private
    attr_reader :test_base_path

    # @return [#read] the data loader that responds to a `#read` message,
    #   returning a Hash data structure
    # @api private
    attr_reader :loader

    # @return [Symbol] the logging verbosity level
    # @api private
    attr_accessor :log_level

    # Creates a new configuration, representing a particular testing
    # configuration for a project.
    #
    # @param [Hash] options configuration
    # @option options [#read] :loader an object that responds to `#read` with
    #   a Hash structure suitable for manipulating
    #   (default: `Kitchen::Loader::YAML.new`)
    # @option options [String] :kitchen_root an absolute path to the root of a
    #   Test Kitchen project, usually containing a `.kitchen.yml` file
    #   (default `Dir.pwd`)
    # @option options [String] :log_root an absolute path to the directory
    #   into which all Test Kitchen log files will be written
    #   (default: `"#{kitchen_root}/.kitchen/logs"`)
    # @option options [String] :test_base_path an absolute path to the
    #   directory containing test suites and other testing-related files and
    #   directories (default: `"#{kitchen_root}/test/integration"`)
    # @option options [Symbol] :log_level the log level verbosity that the
    #   loggers will use when outputing information (default: `:info`)
    def initialize(options = {})
      @loader         = options.fetch(:loader) { Kitchen::Loader::YAML.new }
      @kitchen_root   = options.fetch(:kitchen_root) { Dir.pwd }
      @log_level      = options.fetch(:log_level) { Kitchen::DEFAULT_LOG_LEVEL }
      @log_root       = options.fetch(:log_root) { default_log_root }
      @test_base_path = options.fetch(:test_base_path) { default_test_base_path }
    end

    # @return [Collection<Instance>] all instances, resulting from all
    #   platform and suite combinations
    def instances
      @instances ||= Collection.new(build_instances)
    end

    # @return [Collection<Platform>] all defined platforms which will be used
    #   in convergence integration
    def platforms
      @platforms ||= Collection.new(
        data.platform_data.map { |pdata| Platform.new(pdata) })
    end

    # @return [Collection<Suite>] all defined suites which will be used in
    #   convergence integration
    def suites
      @suites ||= Collection.new(
        data.suite_data.map { |sdata| Suite.new(sdata) })
    end

    private

    # Builds the filtered list of Instance objects.
    #
    # @return [Array<Instance] an array of Instances
    # @api private
    def build_instances
      filter_instances.map.with_index do |(suite, platform), index|
        new_instance(suite, platform, index)
      end
    end

    # Returns an object which can generate configuration hashes for all the
    # primary Test Kitchen objects such as Drivers, Provisioners, etc.
    #
    # @return [DataMunger] a data manipulator
    # @api private
    def data
      @data ||= DataMunger.new(loader.read, kitchen_config)
    end

    # Determines the default absolute path to a log directory, based on the
    # value of `#kitchen_root`.
    #
    # @return [String] an absolute path to the log directory
    # @api private
    def default_log_root
      File.join(kitchen_root, Kitchen::DEFAULT_LOG_DIR)
    end

    # Determines the default absolute path to the testing files directory,
    # based on the the value of `#kitchen_root`.
    #
    # @return [String] an absolute path to the testing files directory
    # @api private
    def default_test_base_path
      File.join(kitchen_root, Kitchen::DEFAULT_TEST_DIR)
    end

    # Generates a filtered Array of tuples (Suite/Platform pairs) which is the
    # cartesian product of suites and platforms. A Suite has two optional
    # arrays (`#includes` and `#excludes`) which can be used to drop or
    # select certain Platforms with which to join.
    #
    # @return [Array<Array<Suite, Platform>>] an Array of Suite/Platform
    #   tuples
    # @api private
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

    # Determines the String name for an Instance, given a Suite and a Platform.
    #
    # @param suite [Suite,#name] a Suite
    # @param platform [Platform,#name] a Platform
    # @return [String] an Instance name
    # @api private
    def instance_name(suite, platform)
      Instance.name_for(suite, platform)
    end

    # Generates the immutable Test Kitchen configuration and reasonable
    # defaults for Drivers, Provisioners and Transports.
    #
    # @return [Hash] a configuration Hash
    # @api private
    def kitchen_config
      @kitchen_config ||= {
        :defaults => {
          :driver       => Driver::DEFAULT_PLUGIN,
          :provisioner  => Provisioner::DEFAULT_PLUGIN,
          :transport    => Transport::DEFAULT_PLUGIN
        },
        :kitchen_root   => kitchen_root,
        :test_base_path => test_base_path,
        :log_level      => log_level
      }
    end

    # Builds a newly configured Busser object, for a given a Suite and Platform.
    #
    # @param suite [Suite,#name] a Suite
    # @param platform [Platform,#name] a Platform
    # @return [Busser] a new Busser object
    # @api private
    def new_busser(suite, platform)
      bdata = data.busser_data_for(suite.name, platform.name)
      Busser.new(suite.name, bdata)
    end

    # Builds a newly configured Driver object, for a given Suite and Platform.
    #
    # @param suite [Suite,#name] a Suite
    # @param platform [Platform,#name] a Platform
    # @return [Driver] a new Driver object
    # @api private
    def new_driver(suite, platform)
      ddata = data.driver_data_for(suite.name, platform.name)
      Driver.for_plugin(ddata[:name], ddata)
    end

    # Builds a newly configured Instance object, for a given Suite and
    # Platform.
    #
    # @param suite [Suite,#name] a Suite
    # @param platform [Platform,#name] a Platform
    # @param index [Integer] an index used for colorizing output
    # @return [Instance] a new Instance object
    # @api private
    def new_instance(suite, platform, index)
      Instance.new(
        :busser       => new_busser(suite, platform),
        :driver       => new_driver(suite, platform),
        :logger       => new_logger(suite, platform, index),
        :suite        => suite,
        :platform     => platform,
        :provisioner  => new_provisioner(suite, platform),
        :transport    => new_transport(suite, platform),
        :state_file   => new_state_file(suite, platform)
      )
    end

    # Builds a newly configured Logger object, for a given Suite and
    # Platform.
    #
    # @param suite [Suite,#name] a Suite
    # @param platform [Platform,#name] a Platform
    # @param index [Integer] an index used for colorizing output
    # @return [Logger] a new Logger object
    # @api private
    def new_logger(suite, platform, index)
      name = instance_name(suite, platform)
      Logger.new(
        :stdout   => STDOUT,
        :color    => Color::COLORS[index % Color::COLORS.size].to_sym,
        :logdev   => File.join(log_root, "#{name}.log"),
        :level    => Util.to_logger_level(log_level),
        :progname => name
      )
    end

    # Builds a newly configured Provisioner object, for a given Suite and
    # Platform.
    #
    # @param suite [Suite,#name] a Suite
    # @param platform [Platform,#name] a Platform
    # @return [Provisioner] a new Provisioner object
    # @api private
    def new_provisioner(suite, platform)
      pdata = data.provisioner_data_for(suite.name, platform.name)
      Provisioner.for_plugin(pdata[:name], pdata)
    end

    # Builds a newly configured Transport object, for a given Suite and
    # Platform.
    #
    # @param suite [Suite,#name] a Suite
    # @param platform [Platform,#name] a Platform
    # @return [Transport] a new Transport object
    # @api private
    def new_transport(suite, platform)
      tdata = data.transport_data_for(suite.name, platform.name)
      Transport.for_plugin(tdata[:name], tdata)
    end

    # Builds a newly configured StateFile object, for a given Suite and
    # Platform.
    #
    # @param suite [Suite,#name] a Suite
    # @param platform [Platform,#name] a Platform
    # @return [StateFile] a new StateFile object
    # @api private
    def new_state_file(suite, platform)
      StateFile.new(kitchen_root, instance_name(suite, platform))
    end
  end
end

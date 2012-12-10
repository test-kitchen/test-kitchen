# -*- encoding: utf-8 -*-

require 'forwardable'
require 'vagrant'

require 'jamie'

module Jamie

  module Vagrant

    # A Vagrant confiuration class which wraps a Jamie::Config instance.
    class Config < ::Vagrant::Config::Base
      extend Forwardable

      def_delegators :@config, :suites, :suites=, :platforms, :platforms=,
        :instances, :yaml_file, :yaml_file=, :log_level, :log_level=,
        :test_base_path, :test_base_path=, :yaml_data

      def initialize
        @config = Jamie::Config.new
      end
    end

    # Defines all Vagrant virtual machines, one for each instance.
    #
    # @param config [Vagrant::Config::Top] Vagrant top level config object
    def self.define_vms(config)
      config.jamie.instances.each do |instance|
        define_vagrant_vm(config, instance)
      end
    end

    private

    def self.define_vagrant_vm(config, instance)
      driver = instance.platform.driver

      config.vm.define instance.name do |c|
        c.vm.box = driver['box']
        c.vm.box_url = driver['box_url'] if driver['box_url']
        c.vm.host_name = "#{instance.name}.vagrantup.com"
        c.vm.customize ["modifyvm", :id, "--memory", driver['memory']]

        c.vm.provision :chef_solo do |chef|
          chef.log_level = config.jamie.log_level
          chef.run_list = instance.run_list
          chef.json = instance.json
          chef.data_bags_path = calculate_data_bags_path(config, instance)
        end
      end
    end

    def self.calculate_data_bags_path(config, instance)
      base_path = config.jamie.test_base_path
      instance_data_bags_path = File.join(base_path, instance.name, "data_bags")
      common_data_bags_path = File.join(base_path, "data_bags")

      if File.directory?(instance_data_bags_path)
        instance_data_bags_path
      elsif File.directory?(common_data_bags_path)
        common_data_bags_path
      else
        nil
      end
    end
  end
end

Vagrant.config_keys.register(:jamie) { Jamie::Vagrant::Config }

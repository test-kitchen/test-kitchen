# -*- encoding: utf-8 -*-

require 'forwardable'
require 'vagrant'

require 'jamie'

module Jamie
  module Vagrant
    class Config < ::Vagrant::Config::Base
      extend Forwardable

      def_delegators :@config, :yaml, :yaml=, :platforms, :platforms=,
        :suites, :suites=, :log_level, :log_level=,
        :data_bags_base_path, :data_bags_base_path=, :yaml_data

      def initialize
        @config = Jamie::Config.new
      end
    end

    def self.init!
      ::Vagrant.config_keys.register(:jamie) { Jamie::Vagrant::Config }
    end

    def self.define_vms(config)
      config.jamie.suites.each do |suite|
        config.jamie.platforms.each do |platform|
          define_vagrant_vm(config, suite, platform)
        end
      end
    end

    private

    def self.define_vagrant_vm(config, suite, platform)
      name = "#{suite.name}-#{platform.name}".gsub(/_/, '-').gsub(/\./, '')

      config.vm.define name do |c|
        c.vm.box = platform.vagrant_box
        c.vm.box_url = platform.vagrant_box_url if platform.vagrant_box_url
        c.vm.host_name = "#{name}.vagrantup.com"
        c.vm.customize ["modifyvm", :id, "--memory", "256"]

        c.vm.provision :chef_solo do |chef|
          chef.log_level = config.jamie.log_level
          chef.run_list = platform.base_run_list + Array(suite.run_list)
          chef.json = suite.json
          chef.data_bags_path = calculate_data_bags_path(config, name)
        end
      end
    end

    def self.calculate_data_bags_path(config, instance_name)
      base_path = config.jamie.data_bags_base_path
      instance_data_bags_path = File.join(base_path, instance_name, "data_bags")
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

Jamie::Vagrant.init!

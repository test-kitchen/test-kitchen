require 'vagrant'
require 'test-kitchen/vagrant/command'
require 'test-kitchen/vagrant/config'

module TestKitchen
  module Vagrant
    # Vagrantfile config callbacks
    def self.config_callbacks
      @config_callbacks ||= {}
    end

    def self.configure(type, &block)
      # Store it for later
      @config_callbacks ||= {}
      @config_callbacks[type] ||= []
      @config_callbacks[type] << block
    end
  end
end
Vagrant.config_keys.register(:tk) { TestKitchen::Vagrant::Config }
Vagrant.commands.register(:tk) { TestKitchen::Vagrant::Command::Tk }

# override built in `vagrant up`
#Vagrant.commands.register(:up) { TestKitchen::Vagrant::Command::Up }


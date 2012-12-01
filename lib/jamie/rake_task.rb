# -*- encoding: utf-8 -*-

require 'rake'
require 'rake/tasklib'

require 'jamie'

module Jamie
  module Rake
    class Tasks < ::Rake::TaskLib
      attr_accessor :name

      def initialize(name = :jamie)
        @name = name
        yield self if block_given?
        define
      end

      def define
        config = Jamie::Config.new

        namespace(name) do
          config.instances.each do |instance_name|
            desc "Run #{instance_name} integration"
            task(instance_name) do
              puts "-----> Cleaning up any prior instances of #{instance_name}"
              config.backend.destroy(instance_name)
              puts "-----> Bringing up instance #{instance_name}"
              config.backend.up(instance_name)
              puts "-----> Instance #{instance_name} completed."
            end

            namespace(instance_name) do
              desc "Destroy #{instance_name} instance"
              task :destroy do
                puts "-----> Destroying any prior instances of #{instance_name}"
                config.backend.destroy(instance_name)
                puts "-----> Instance #{instance_name} destruction complete."
              end
            end
          end

          desc "Destroy all instances"
          task :destroy => config.instances.map { |i| "#{i}:destroy" }
        end

        desc "Run Jamie integration"
        task name => config.instances
      end
    end
  end
end

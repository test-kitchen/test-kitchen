# -*- encoding: utf-8 -*-

require 'rake'
require 'rake/tasklib'

require 'jamie'

module Jamie
  class RakeTasks < ::Rake::TaskLib
    attr_accessor :name
    attr_accessor :config

    def initialize(name = :jamie)
      @name = name
      @config = Jamie::Config.new
      yield self if block_given?
      define
    end

    def define
      namespace(name) do
        config.instances.each do |instance|
          desc "Run #{instance.name} test instance"
          task(instance.name) do
            instance.test
          end

          namespace(instance.name) do
            desc "Destroy #{instance.name} test instance"
            task :destroy do
              instance.destroy
            end
          end
        end

        desc "Destroy all instances"
        task :destroy => config.instances.map { |i| "#{i.name}:destroy" }
      end

      desc "Run Jamie integration"
      task name => config.instances.map { |i| i.name }
    end
  end
end

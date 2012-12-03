# -*- encoding: utf-8 -*-

require 'rake'
require 'rake/tasklib'

require 'jamie'

module Jamie
  # Jamie Rake task generator.
  class RakeTasks < ::Rake::TaskLib
    # @return [String] prefix name of all Jamie tasks
    attr_accessor :name

    # @return [Jamie::Config] a Jamie config object
    attr_accessor :config

    # Creates Jamie Rake tasks and allows the callee to configure it.
    #
    # @yield [self] gives itself to the block
    def initialize(name = :jamie)
      @name = name
      @config = Jamie::Config.new
      yield self if block_given?
      define
    end

    private

    def define
      namespace name do
        config.instances.each do |instance|
          desc "Run #{instance.name} test instance"
          task instance.name do
            instance.test
          end

          namespace instance.name do
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
      task name => config.instances.map { |i| "#{name}:#{i.name}" }
    end
  end
end

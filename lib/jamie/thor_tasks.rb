# -*- encoding: utf-8 -*-

require 'thor'

require 'jamie'

module Jamie

  # Jamie Thor task generator.
  class ThorTasks < Thor

    namespace :jamie

    # Creates Jamie Thor tasks and allows the callee to configure it.
    #
    # @yield [self] gives itself to the block
    def initialize(*args)
      super
      @config = Jamie::Config.new
      yield self if block_given?
      define
    end

    private

    attr_reader :config

    def define
      config.instances.each do |instance|
        self.class.desc instance.name, "Run #{instance.name} test instance"
        self.class.send(:define_method, instance.name.gsub(/-/, '_')) do
          instance.test
        end
      end

      self.class.desc "all", "Run all test instances"
      self.class.send(:define_method, :all) do
        config.instances.each { |i| invoke i.name.gsub(/-/, '_')  }
      end
    end
  end
end

# -*- encoding: utf-8 -*-

require 'rake/tasklib'

require 'jamie'

module Jamie

  # Jamie Rake task generator.
  class RakeTasks < ::Rake::TaskLib

    # Creates Jamie Rake tasks and allows the callee to configure it.
    #
    # @yield [self] gives itself to the block
    def initialize
      @config = Jamie::Config.new
      yield self if block_given?
      define
    end

    private

    attr_reader :config

    def define
      namespace "jamie" do
        config.instances.each do |instance|
          desc "Run #{instance.name} test instance"
          task instance.name { instance.test(:always) }
        end

        desc "Run all test instances"
        task "all" => config.instances.map { |i| i.name }
      end
    end
  end
end

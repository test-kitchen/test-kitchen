require 'test-kitchen/cli'
require 'test-kitchen/runner'

module TestKitchen
  module CLI
    class Kitchen
      class Test < Kitchen

        banner "kitchen test (options)"

        def run
          options = {
            :platform => config[:platform],
            :project => config[:project]
          }
          runner = TestKitchen::Runner.targets[config[:runner]].new(env, options)
          runner.test
        end

      end
    end
  end
end

require 'test-kitchen/cli'
require 'test-kitchen/runner'

module TestKitchen
  module CLI
    class Kitchen
      class Status < Kitchen

        banner "kitchen status (options)"

        def run
          runner = TestKitchen::Runner.targets[config[:runner]].new(env)
          runner.status
        end

      end
    end
  end
end

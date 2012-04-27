require 'test-kitchen/cli'
require 'test-kitchen/runner'

module TestKitchen
  module CLI
    class Kitchen
      class Destroy < Kitchen

        banner "kitchen destroy (options)"

        def run
          options = {
            :platform => config[:platform],
            :project => config[:project]
          }

          runner = TestKitchen::Runner.targets[config[:runner]].new(env, options)
          runner.destroy
        end

      end
    end
  end
end

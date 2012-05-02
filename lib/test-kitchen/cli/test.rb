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
            :configuration => config[:configuration]
          }
          runner = TestKitchen::Runner.targets[env.project.runner].new(env, options)
          runner.provision
          runner.test
        end

      end
    end
  end
end

require 'test-kitchen/cli'
require 'test-kitchen/runner'

module TestKitchen
  module CLI
    class Kitchen
      class Ssh < Kitchen

        banner "kitchen ssh (options)"

        def run
          options = {
            :platform => config[:platform],
          }
          runner = TestKitchen::Runner.targets[env.project.runner].new(env, options)
          runner.ssh
        end

      end
    end
  end
end

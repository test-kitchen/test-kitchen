require 'test-kitchen/cli'
require 'test-kitchen/runner'

module TestKitchen
  module CLI
    class Kitchen
      class Test < Kitchen

        banner "kitchen test (options)"

        def run
          # TODO: Limit configurations run based on options
          #options = {
          #  :platform => config[:platform],
          #  :configuration => config[:configuration]
          #}
          env.project.each_build(['natty', 'centos-6']) do |platform,configuration|
            runner = TestKitchen::Runner.targets[env.project.runner].new(
              env, {:platform => platform, :configuration => configuration})
            # TODO: Rethink this, no need for linting to be repeated
            runner.preflight_check
            begin
              # TODO: Cookbook assembly also doesn't need to be repeated
              runner.provision
              runner.test
            ensure
              runner.destroy
            end
          end
        end

      end
    end
  end
end

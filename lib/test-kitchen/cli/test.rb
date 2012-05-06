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
          warn_for_non_buildable_platforms(env.platform_names)
          env.project.each_build(env.platform_names) do |platform,configuration|
            runner = TestKitchen::Runner.for_platform(env,
              {:platform => platform, :configuration => configuration})

            # TODO: Remove, just for development
            next if runner.class == TestKitchen::Runner::Vagrant

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

        private

        def warn_for_non_buildable_platforms(platform_names)
          if env.project.respond_to?(:non_buildable_platforms)
            env.project.non_buildable_platforms(platform_names).each do |platform|
              env.ui.info("Cookbook metadata specifies an unrecognised platform that will not be tested: #{platform}", :red)
            end
          end
        end

      end
    end
  end
end

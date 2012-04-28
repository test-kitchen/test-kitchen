require 'test-kitchen/cli'

module TestKitchen
  module CLI
    class Kitchen
      class ProjectInfo < Kitchen

        banner "kitchen project info (options)"

        def run
          ui.info("Project: ", :green, :bold)
          ui.info("  #{env.project.name}\n")
          ui.info("Configurations: ", :yellow)
          if env.project.configurations.any?
            env.project.configurations.each do |config|
              ui.info("  #{config.name}")
            end
          else
            ui.info("  default")
          end
        end

      end
    end
  end
end

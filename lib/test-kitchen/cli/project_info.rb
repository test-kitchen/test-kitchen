require 'test-kitchen/cli'

module TestKitchen
  module CLI
    class Kitchen
      class ProjectInfo < Kitchen

        banner "kitchen project info (options)"

        def run
          ui.info("Project: #{env.project.name}", :green, :bold)
          if env.project.configurations.any?
            ui.info("Configurations: ", :yellow)
            env.project.configurations.each do |config|
              ui.info "  #{config.name}"
            end
          else
            ui.info("")
          end
        end

      end
    end
  end
end

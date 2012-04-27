require 'test-kitchen/cli'

module TestKitchen
  module CLI
    class Kitchen
      class ProjectList < Kitchen

        banner "kitchen project list (options)"

        def run
          env.projects.each do |project|
            ui.info "  #{project.name}"
          end
        end

      end
    end
  end
end

require 'test-kitchen/cli'

module TestKitchen
  module CLI
    class Kitchen
      class ProjectList < Kitchen

        banner "kitchen project list (options)"

        def run
          TestKitchen.projects.each do |project|
            $stdout.puts "  #{project.name}"
          end
        end

      end
    end
  end
end

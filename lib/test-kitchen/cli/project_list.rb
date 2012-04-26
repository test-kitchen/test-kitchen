require 'test-kitchen/cli'

module TestKitchen
  module CLI
    class Kitchen
      class ProjectList < Kitchen

        banner "kitchen project list (options)"

        def run
          TestKitchen.projects.each_key do |project|
            $stdout.puts "  #{project}"
          end
        end

      end
    end
  end
end

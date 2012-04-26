require 'test-kitchen/cli'

module TestKitchen
  module CLI
    class Kitchen
      class PlatformList < Kitchen

        banner "kitchen platform list (options)"

        def run
          TestKitchen.platforms.each_pair do |platform, versions|
            versions.each_key do |version|
              $stdout.puts "  #{platform}-#{version}"
            end
          end
        end

      end
    end
  end
end

require 'test-kitchen/cli'

module TestKitchen
  module CLI
    class Kitchen
      class PlatformList < Kitchen

        banner "kitchen platform list (options)"

        def run
          env.platforms.values.each do |platform|
            platform.versions.values.each do |version|
              ui.info "  #{platform.name}-#{version.name}"
            end
          end
        end

      end
    end
  end
end

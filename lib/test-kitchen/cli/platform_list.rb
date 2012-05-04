require 'test-kitchen/cli'

module TestKitchen
  module CLI
    class Kitchen
      class PlatformList < Kitchen

        banner "kitchen platform list (options)"

        def run
          env.platform_names.each do |platform|
            ui.info "  #{platform}"
          end
        end

      end
    end
  end
end

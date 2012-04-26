require 'test-kitchen/cli'
require 'test-kitchen/scaffold'

module TestKitchen
  module CLI
    class Kitchen
      class Init < Kitchen

        banner "kitchen init"

        def run
          scaffold = TestKitchen::Scaffold.new
          scaffold.generate(Dir.pwd)
        end

      end
    end
  end
end

require 'chef'

module TestKitchen
  module DSL

    module BasicDSL
      def integration_test(name, &block)
        Project.new(name, &block)
      end
    end
    module CookbookDSL
      def cookbook(name, &block)
        CookbookProject.new(name, &block)
      end
    end

    class File
      include BasicDSL
      include CookbookDSL

      def load(path)
        self.instance_eval(::File.read(path))
      end
    end

  end
end

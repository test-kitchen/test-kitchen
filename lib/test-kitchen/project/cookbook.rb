module TestKitchen
  module Project
    class Cookbook < Ruby

      attr_writer :lint

      def lint(arg=nil)
        set_or_return(:lint, arg, {:default => true})
      end
    end
  end
end

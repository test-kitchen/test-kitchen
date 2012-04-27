module TestKitchen
  module Project
    class Ruby < Base

      attr_writer :rvm

      def rvm(arg=nil)
        set_or_return(:rvm, arg, {})
      end
    end
  end
end

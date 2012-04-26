module TestKitchen
  module Runner
    class Base

      attr_accessor :platform
      attr_accessor :project

      def initialize(opts={})
        @platform = opts[:platform]
        @project = opts[:project]
      end

      def provision
        raise NotImplementedError
      end

      def test
        raise NotImplementedError
      end

      def status
        raise NotImplementedError
      end

      def destroy
        raise NotImplementedError
      end

      def ssh
        raise NotImplementedError
      end

      def self.inherited(subclass)
        key = subclass.to_s.split('::').last.downcase
        Runner.targets[key] = subclass
      end

    end

    def self.targets
      @@targets ||= {}
    end
  end
end

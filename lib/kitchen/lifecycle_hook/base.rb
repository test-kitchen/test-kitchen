module Kitchen
  class LifecycleHook
    class Base
      # @return [Kitchen::LifecycleHooks]
      attr_reader :lifecycle_hooks

      # return [String]
      attr_reader :phase

      # return [Hash]
      attr_reader :hook

      # @param lifecycle_hooks [Kitchen::LifecycleHooks]
      # @param phase [String]
      # @param hook [Hash]
      def initialize(lifecycle_hooks, phase, hook)
        @lifecycle_hooks = lifecycle_hooks
        @phase = phase
        @hook = hook
      end

      # return [void]
      def run
        raise NotImplementedError
      end

      # @return [TrueClass, FalseClass]
      def should_run?
        if !includes.empty?
          includes.include?(platform_name)
        elsif !excludes.empty?
          !excludes.include?(platform_name)
        else
          true
        end
      end

      # @return [Logger] the lifecycle hooks's logger
      #   otherwise
      # @api private
      def logger
        lifecycle_hooks.send(:logger)
      end

      private

      # @return [Kitchen::Instance]
      def instance
        lifecycle_hooks.instance
      end

      # @return [Hash]
      def config
        lifecycle_hooks.send(:config)
      end

      # @return [Kitchen::StateFile]
      def state_file
        instance.state_file
      end

      # @return [Array<String>] names of excluded platforms
      def excludes
        @excludes ||= hook.fetch(:excludes, [])
      end

      # @return [Array<String>] names of only included platforms
      def includes
        @includes ||= hook.fetch(:includes, [])
      end

      # @return [String]
      def platform_name
        instance.platform.name
      end
    end
  end
end

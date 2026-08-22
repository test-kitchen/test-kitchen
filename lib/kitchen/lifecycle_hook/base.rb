require_relative "../platform_filter"

module Kitchen
  # Namespace for the lifecycle hook implementations that run user-defined
  # commands around instance actions.
  class LifecycleHook
    # Base class for a lifecycle hook implementation.
    #
    # A hook is bound to a single phase (for example `pre_create`) and decides,
    # via `#should_run?`, whether it applies to the instance's platform before
    # `#run` carries out the command.
    class Base
      # @return [Kitchen::LifecycleHooks]
      attr_reader :lifecycle_hooks

      # @return [String] the lifecycle phase this hook is bound to
      attr_reader :phase

      # @return [Hash] the raw hook configuration
      attr_reader :hook

      # @param lifecycle_hooks [Kitchen::LifecycleHooks]
      # @param phase [String]
      # @param hook [Hash]
      def initialize(lifecycle_hooks, phase, hook)
        @lifecycle_hooks = lifecycle_hooks
        @phase = phase
        @hook = hook
      end

      # Carries out the hook's command. Subclasses must implement this.
      #
      # @return [void]
      # @raise [NotImplementedError] unless overridden by a subclass
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

      # @return [Logger] the lifecycle hook's logger
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
        lifecycle_hooks.state_file
      end

      # @return [Array<PlatformFilter>] names of excluded platforms
      def excludes
        @excludes ||= PlatformFilter.convert(hook.fetch(:excludes, []))
      end

      # @return [Array<PlatformFilter>] names of only included platforms
      def includes
        @includes ||= PlatformFilter.convert(hook.fetch(:includes, []))
      end

      # @return [String]
      def platform_name
        instance.platform.name
      end
    end
  end
end

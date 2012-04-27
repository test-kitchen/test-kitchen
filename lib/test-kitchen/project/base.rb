require 'chef/mixin/params_validate'

module TestKitchen
  module Project
    class Base
      include Chef::Mixin::ParamsValidate

      attr_reader :name
      attr_writer :language, :runtimes, :install, :script, :platforms, :configurations
      attr_accessor :vm

      def initialize(name, &block)
        raise ArgumentError, "Project name must be specified" if name.nil? || name.empty?
        @name = name
        @configurations = []
        instance_eval(&block) if block_given?
      end

      def configuration(name)
        @configurations << self.class.new(name)
      end

      def configurations
        @configurations
      end

      def platforms
        @platforms ||= []
      end

      def exclude(exclusion)
        if exclusion.key?(:platform)
          platforms.delete(exclusion[:platform])
        end
      end

      def language(arg=nil)
        set_or_return(:language, arg, :default => 'ruby')
      end

      def runtimes(arg=nil)
        set_or_return(:runtimes, arg, :default =>
          if language == 'ruby' and self.respond_to?(:rvm)
            rvm ? rvm : ['1.9.2']
          else
            []
          end)
      end

      def install(arg=nil)
        set_or_return(:install, arg,
          :default => language == 'ruby' ? 'bundle install' : '')
      end

      def script(arg=nil)
        set_or_return(:script, arg, :default => 'rspec spec')
      end

      def memory(arg=nil)
        set_or_return(:memory, arg, {})
      end
    end
  end
end

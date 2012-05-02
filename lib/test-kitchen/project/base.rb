require 'chef/mixin/params_validate'

module TestKitchen
  module Project
    class Base
      include Chef::Mixin::ParamsValidate

      PROJECT_ROOT_INDICATORS = ["Gemfile", "metadata.rb"]

      attr_reader :name, :guest_source_root, :guest_test_root
      attr_writer :language, :runtimes, :install, :script
      attr_accessor :vm

      def initialize(name, &block)
        raise ArgumentError, "Project name must be specified" if name.nil? || name.empty?
        @name = name
        @configurations = []
        @guest_source_root = '/test-kitchen/source'
        @guest_test_root = '/test-kitchen/test'
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

      def run_list
        [case runner
          when 'lxc' then 'test-kitchen::lxc'
          else 'test-kitchen::default'
        end]
      end

      def run_list_extras(arg=nil)
        set_or_return(:run_list_extras, arg, :default => [])
      end

      def language(arg=nil)
        set_or_return(:language, arg, :default => 'ruby')
      end

      def runtimes(arg=nil)
        set_or_return(:runtimes, arg, :default =>
          if language == 'ruby' || language == 'chef'
            ['1.9.2']
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

      def root_path
        return @root_path if defined?(@root_path)

        root_finder = lambda do |path|
          found = PROJECT_ROOT_INDICATORS.find do |rootfile|
            File.exist?(File.join(path.to_s, rootfile))
          end

          return path if found
          return nil if path.root? || !File.exist?(path)
          root_finder.call(path.parent)
        end

        @root_path = root_finder.call(Dir.pwd)
      end

      def update_code_command
        "rsync -aHv --update --progress --checksum #{guest_source_root}/ #{guest_test_root}"
      end

      def install_command(runtime=nil)
        raise NotImplementedError
      end

      def test_command(runtime=nil)
        raise NotImplementedError
      end

      def to_hash
        hash = {}
        self.instance_variables.each do |var|
          hash[var[1..-1].to_sym] = self.instance_variable_get(var)
        end
        hash
      end
    end
  end
end

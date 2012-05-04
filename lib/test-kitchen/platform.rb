require 'hashr'
require 'chef/mixin/params_validate'

module TestKitchen
  class Platform
    include Chef::Mixin::ParamsValidate

    attr_reader :name, :versions

    def initialize(name, &block)
      raise ArgumentError, "Platform name must be specified" if name.nil? || name.empty?

      @name = name
      @versions = {}
      instance_eval(&block) if block_given?
    end

    def version(name, &block)
      versions[name.to_s] = Version.new(name, &block)
    end

    class Version
      include Chef::Mixin::ParamsValidate

      attr_reader :name
      attr_writer :box, :box_url, :lxc_url

      def initialize(name, &block)
        raise ArgumentError, "Version name must be specified" if name.nil? || name.empty?
        @name = name
        instance_eval(&block) if block_given?
      end

      def box(arg=nil)
        set_or_return(:box, arg, {})
      end

      def box_url(arg=nil)
        set_or_return(:box_url, arg, {})
      end

      def lxc_url(arg=nil)
        set_or_return(:lxc_url, arg, {})
      end

    end

  end
end

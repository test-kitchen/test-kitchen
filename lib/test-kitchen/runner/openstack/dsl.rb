require 'test-kitchen/runner/openstack/environment'

module TestKitchen
  class Openstack
    include Chef::Mixin::ParamsValidate

    attr_writer :username, :password, :tenant, :auth_url, :floating_ip

    def initialize(&block)
      instance_eval(&block) if block_given?
    end

    def username(arg=nil)
      set_or_return(:username, arg, {})
    end

    def password(arg=nil)
      set_or_return(:password, arg, {})
    end

    def tenant(arg=nil)
      set_or_return(:tenant, arg, {})
    end

    def auth_url(arg=nil)
      set_or_return(:auth_url, arg, {})
    end

    def floating_ip(arg=nil)
      set_or_return(:floating_ip, arg, {})
    end
  end
end

module TestKitchen
  module DSL
    module BasicDSL
      def openstack(&block)
        TestKitchen::Environment::Openstack.config = TestKitchen::Openstack.new(&block)
      end
    end
  end
end

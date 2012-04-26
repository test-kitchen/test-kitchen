module TestKitchen
  module Vagrant
    class Config < ::Vagrant::Config::Base

      attr_accessor :projects

      def initialize
        @projects = nil
      end

      def validate(env, errors)

      end
    end
  end
end

#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

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
      attr_writer :box, :box_url

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

    end

  end
end

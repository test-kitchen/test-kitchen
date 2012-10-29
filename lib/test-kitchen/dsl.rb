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
require 'test-kitchen/project'
require 'test-kitchen/platform'
require 'test-kitchen/runner/openstack/dsl'

module TestKitchen
  module DSL

    module BasicDSL
      def integration_test(name, &block)
        env.project = Project::Ruby.new(name.to_s, &block)
      end

      def platform(name, &block)
        env.platforms[name.to_s] = Platform.new(name, &block)
      end

      def default_runner(name)
        env.default_runner = name
      end
    end
    module CookbookDSL
      def cookbook(name, &block)
        env.project = Project::Cookbook.new(name.to_s, &block)
      end
    end

    class File
      include BasicDSL
      include CookbookDSL

      attr_reader :env

      def load(path, env)
        @env = env
        begin
          self.instance_eval(::File.read(path))
        rescue SyntaxError
          env.ui.info('Your Kitchenfile could not be loaded. Please check it for errors.', :red)
          raise
        end
      end
    end

  end
end

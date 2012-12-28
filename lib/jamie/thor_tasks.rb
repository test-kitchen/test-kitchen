# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'thor'

require 'jamie'

module Jamie

  # Jamie Thor task generator.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class ThorTasks < Thor

    namespace :jamie

    # Creates Jamie Thor tasks and allows the callee to configure it.
    #
    # @yield [self] gives itself to the block
    def initialize(*args)
      super
      @config = Jamie::Config.new
      yield self if block_given?
      define
    end

    private

    attr_reader :config

    def define
      config.instances.each do |instance|
        self.class.desc instance.name, "Run #{instance.name} test instance"
        self.class.send(:define_method, instance.name.gsub(/-/, '_')) do
          instance.test(:always)
        end
      end

      self.class.desc "all", "Run all test instances"
      self.class.send(:define_method, :all) do
        config.instances.each { |i| invoke i.name.gsub(/-/, '_')  }
      end
    end
  end
end

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

require "rake/tasklib"

require "kitchen"

module Kitchen

  # Kitchen Rake task generator.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class RakeTasks < ::Rake::TaskLib

    # Creates Kitchen Rake tasks and allows the callee to configure it.
    #
    # @yield [self] gives itself to the block
    def initialize(cfg = {})
      @loader = Kitchen::Loader::YAML.new(
        :project_config => ENV["KITCHEN_YAML"],
        :local_config => ENV["KITCHEN_LOCAL_YAML"],
        :global_config => ENV["KITCHEN_GLOBAL_YAML"]
      )
      @config = Kitchen::Config.new(
        { :loader => @loader }.merge(cfg)
      )
      Kitchen.logger = Kitchen.default_file_logger(nil, false)
      yield self if block_given?
      define
    end

    private

    # @return [Config] a Kitchen::Config
    attr_reader :config

    # Generates a test Rake task for each instance and one to test all
    # instances in serial.
    #
    # @api private
    def define
      namespace "kitchen" do
        config.instances.each do |instance|
          desc "Run #{instance.name} test instance"
          task instance.name do
            instance.test(:always)
          end
        end

        desc "Run all test instances"
        task "all" => config.instances.map(&:name)
      end
    end
  end
end

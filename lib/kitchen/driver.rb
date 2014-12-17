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

require "thor/util"

module Kitchen

  # A driver is responsible for carrying out the lifecycle activities of an
  # instance, such as creating, converging, and destroying an instance.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  module Driver

    # Default driver plugin to use
    DEFAULT_PLUGIN = "dummy".freeze

    # Returns an instance of a driver given a plugin type string.
    #
    # @param plugin [String] a driver plugin type, which will be constantized
    # @param config [Hash] a configuration hash to initialize the driver
    # @return [Driver::Base] a driver instance
    # @raise [ClientError] if a driver instance could not be created
    # @raise [UserError] if the driver's dependencies could not be met
    def self.for_plugin(plugin, config)
      first_load = require("kitchen/driver/#{plugin}")

      str_const = Thor::Util.camel_case(plugin)
      klass = const_get(str_const)
      object = klass.new(config)
      object.verify_dependencies if first_load
      object
    rescue UserError
      raise
    rescue LoadError, NameError
      raise ClientError,
        "Could not load the '#{plugin}' driver from the load path." \
          " Please ensure that your driver is installed as a gem or included" \
          " in your Gemfile if using Bundler."
    end
  end
end

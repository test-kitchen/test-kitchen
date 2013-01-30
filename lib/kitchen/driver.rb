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

module Kitchen

  module Driver

    # Returns an instance of a driver given a plugin type string.
    #
    # @param plugin [String] a driver plugin type, which will be constantized
    # @return [Driver::Base] a driver instance
    # @raise [ClientError] if a driver instance could not be created
    def self.for_plugin(plugin, config)
      require "kitchen/driver/#{plugin}"

      str_const = Util.to_camel_case(plugin)
      klass = self.const_get(str_const)
      klass.new(config)
    rescue UserError
      raise
    rescue LoadError
      raise ClientError, "Could not require '#{plugin}' plugin from load path"
    rescue
      raise ClientError, "Failed to create a driver for '#{plugin}' plugin"
    end
  end
end

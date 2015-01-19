# -*- encoding: utf-8 -*-
#
# Author:: Matt Wrock (<matt@mattwrock.com>)
#
# Copyright (C) 2014, Matt Wrock
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

  # A shell is responsible for composing commands in a manner that is
  # compatible with the shell being implemented.
  #
  # @author Matt Wrock <matt@mattwrock.com>
  module Shell

    # Default shell to use
    DEFAULT_SHELL = "bourne".freeze

    # Returns an instance of a shell given a plugin type string.
    #
    # @param plugin [String] a shell plugin type, to be constantized
    # @return [Shell::Base] a driver instance
    # @raise [ClientError] if a shell instance could not be created
    def self.for_plugin(plugin)
      require("kitchen/shell/#{plugin}")

      # str_const = plugin.upcase
      str_const = Thor::Util.camel_case(plugin)
      klass = const_get(str_const)
      klass.new
    rescue LoadError, NameError
      raise ClientError,
        "Could not load the '#{plugin}' shell from the load path." \
          " Please ensure that your shell is installed as a gem or" \
          " included in your Gemfile if using Bundler."
    end
  end
end

# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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
  # A provisioner is responsible for generating the commands necessary to
  # install set up and use a configuration management tool such as Chef and
  # Puppet.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  module Provisioner
    # Default provisioner to use
    DEFAULT_PLUGIN = "chef_solo".freeze

    # Returns an instance of a provisioner given a plugin type string.
    #
    # @param plugin [String] a provisioner plugin type, to be constantized
    # @param config [Hash] a configuration hash to initialize the provisioner
    # @return [Provisioner::Base] a provisioner instance
    # @raise [ClientError] if a provisioner instance could not be created
    def self.for_plugin(plugin, config)
      first_load = require("kitchen/provisioner/#{plugin}")

      str_const = Thor::Util.camel_case(plugin)
      klass = const_get(str_const)
      object = klass.new(config)
      object.verify_dependencies if first_load
      object
    rescue LoadError, NameError
      raise ClientError,
            "Could not load the '#{plugin}' provisioner from the load path." \
              " Please ensure that your provisioner is installed as a gem or" \
              " included in your Gemfile if using Bundler."
    end
  end
end

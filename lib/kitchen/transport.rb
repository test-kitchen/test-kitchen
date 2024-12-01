#
# Author:: Salim Afiune (<salim@afiunemaya.com.mx>)
#
# Copyright (C) 2014, Salim Afiune
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

require_relative "plugin"

module Kitchen
  # A transport is responsible for the communication with an instance,
  # that is remote commands and other actions such as file transfer,
  # login, etc.
  #
  # @author Salim Afiune <salim@afiunemaya.com.mx>
  module Transport
    # Default transport to use
    DEFAULT_PLUGIN = "ssh".freeze

    # Returns an instance of a transport given a plugin type string.
    #
    # @param plugin [String] a transport plugin type, to be constantized
    # @param config [Hash] a configuration hash to initialize the transport
    # @return [Transport::Base] a transport instance
    # @raise [ClientError] if a transport instance could not be created
    def self.for_plugin(plugin, config)
      Kitchen::Plugin.load(self, plugin, config)
    end
  end
end

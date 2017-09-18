#
# Copyright:: Copyright (c) 2017 Chef Software Inc.
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

require "telemetry"
require "singleton"
require "forwardable"

module Kitchen
  class Telemetry
    include Singleton

    def initialize
      @telemetry = ::Telemetry.new(product: "test-kitchen", origin: "command-line")
    end

    def version
      Kitchen::VERSION
    end

    def host
      @host ||= case RUBY_PLATFORM
                when /mswin|mingw|windows/
                  "windows"
                else
                  RUBY_PLATFORM.split("-")[1]
                end
    end

    def send(data = {})
      data[:properties][:host] = host
      data[:properties][:version] = version
      @telemetry.deliver(data)
    end

    class << self
      extend Forwardable
      def_delegators :instance, :send
    end
  end
end

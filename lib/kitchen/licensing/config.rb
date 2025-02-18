# frozen_string_literal: true

# Copyright:: Chef Software Inc.
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

require "chef-licensing"

module Kitchen
  module Licensing
    PRODUCT_NAME = "Test Kitchen Enterprise"
    ENTITLEMENT_ID = "x6f3bc76-a94f-4b6c-bc97-4b7ed2b045c0"
    EXECUTABLE_NAME = "kitchen"
    GLOBAL_LICENSE_SERVER = "https://services.chef.io/licensing"

    class << self
      def configure_licensing
        ChefLicensing.configure do |config|
          config.chef_product_name = PRODUCT_NAME
          config.chef_entitlement_id = ENTITLEMENT_ID
          config.chef_executable_name = EXECUTABLE_NAME
          config.license_server_url = GLOBAL_LICENSE_SERVER
        end
      end
    end
  end
end

# This needs to be called initially to configure the licensing
Kitchen::Licensing.configure_licensing

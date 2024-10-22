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

ChefLicensing.configure do |config|
  config.chef_product_name = "Test Kitchen"
  config.chef_entitlement_id = "x6f3bc76-a94f-4b6c-bc97-4b7ed2b045c0"
  config.chef_executable_name = "kitchen"
  config.license_server_url = "https://services.chef.io/licensing"
  # config.license_server_url   = "https://licensing-acceptance.chef.co/License"
end

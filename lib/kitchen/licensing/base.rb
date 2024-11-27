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

require_relative "config"
require "chef-licensing"
require "faraday_middleware"

module Kitchen
  module Licensing
    class Base

      OMNITRUCK_URLS = {
        "free"       => "https://chefdownload-trial.chef.io",
        "trial"      => "https://chefdownload-trial.chef.io",
        "commercial" => "https://chefdownload-commerical.chef.io",
      }.freeze

      class << self
        def get_license_keys
          keys = ChefLicensing.license_keys
          raise ChefLicensing::InvalidLicense, "A valid license is required to perform this action. Run <kitchen license> command to generate/activate the license." if keys.blank?

          client = get_license_client(keys)

          [keys.last, client.license_type, install_sh_url(client.license_type, keys)]
        end

        def get_license_client(keys)
          ChefLicensing::Api::Client.info(license_keys: keys)
        end

        def install_sh_url(type, keys, ext = "sh")
          OMNITRUCK_URLS[type] + "/install.#{ext}?license_id=#{keys.join(",")}"
        end
      end
    end
  end
end
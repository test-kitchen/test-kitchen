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
        "free"       => "https://trial-acceptance.downloads.chef.co",
        "trial"      => "https://trial-acceptance.downloads.chef.co",
        "commercial" => "https://commercial-acceptance.downloads.chef.co",
      }.freeze

      class << self
        def get_license_keys
          keys = ChefLicensing::LicenseKeyFetcher.fetch
          raise ChefLicensing::InvalidLicense, "A valid license is required to perform this action." if keys.blank?

          is_valid = true # ChefLicensing::LicenseKeyValidator.validate!(keys)
          raise ChefLicensing::InvalidLicense, "The license is not valid" unless is_valid

          client = ChefLicensing::Api::Client.info(license_keys: keys)
          ChefLicensing.check_software_entitlement!

          [keys, client.license_type, install_sh_url(client.license_type, keys), install_ps1_url(client.license_type, keys)]
        end

        def install_sh_url(type, keys)
          OMNITRUCK_URLS[type] + "/install.sh?license_id=#{keys.join(",")}"
        end

        def install_ps1_url(type, keys)
          OMNITRUCK_URLS[type] + "/install.ps1?license_id=#{keys.join(",")}"
        end
      end
    end
  end
end
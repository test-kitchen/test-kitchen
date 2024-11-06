require_relative "../command"
require "kitchen/licensing/base"

module Kitchen
  module Command
    # Command to manage the licenses
    class License < Kitchen::Command::Base
      def call
        case args[0]
        when "list"
          ChefLicensing.list_license_keys_info
        when "add"
          ChefLicensing.add_license
        else
          ChefLicensing.fetch_and_persist.each do |key|
            puts "License_key: #{key}"
          end
        end
      end
    end
  end
end

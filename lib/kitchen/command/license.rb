# frozen_string_literal: true

require_relative "../command"
require "kitchen/licensing/base"

module Kitchen
  module Command
    # Command to manage the licenses
    class License < Kitchen::Command::Base
      BANNER = <<~MSG

      Usage:
        kitchen license            # Add new license or list the activated license(s)
        kitchen license add        # Add a new license
        kitchen license list       # List details of the activated license(s)

      Options:
        [-h/--help]                # Shows the help message
        [--chef-license-key=<KEY>] # License key can be passed as this optional argument as well
                                   # eg: kitchen license --chef-license-key=KEY123
      MSG

      SUB_COMMANDS = %w{add list}.freeze
      OPTIONS      = %w{--chef-license-key -h --help}.freeze

      def call
        result = validate_arguments!

        case result
        when "list"
          ChefLicensing.list_license_keys_info
        when "add"
          ChefLicensing.add_license
        when "help"
          print_help
        else
          ChefLicensing.fetch_and_persist.each do |key|
            puts "License_key: #{key}"
          end
        end
      rescue ChefLicensing::LicenseKeyFetcher::LicenseKeyNotFetchedError
        logger.debug("License key not fetched. Please try again.")
      end

      private

      def print_help(error = nil)
        puts error if error
        puts BANNER
        exit(1) if error
      end

      def validate_arguments!
        return if args.empty?

        if args.any? { |arg| arg == "-h" || arg == "--help" }
          return "help"
        end

        validate_subcommands(args)
        args[0]
      end

      def validate_subcommands(array, last_element = nil)
        return unless array.any?

        # If the last element is --chef-license-key, then the next element should be the license key
        # So no need to validate it
        if last_element == "--chef-license-key"
          validate_subcommands(array[1..-1], array[0])
        else
          unless (SUB_COMMANDS + OPTIONS).include?(array[0].split("=").first)
            print_help("Invalid Option: #{array[0]}")
          end
          validate_subcommands(array[1..-1], array[0])
        end
      end
    end
  end
end

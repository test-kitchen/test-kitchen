# Copyright 2026 Dan Webb
# SPDX-License-Identifier: Apache-2.0

require "json" unless defined?(JSON)

module Kitchen
  module Box
    # Extracts a trusted local Vagrant-format box without evaluating its Vagrantfile.
    # Callers supply a private, empty destination and select their provider payload.
    class LocalArchive
      class InvalidBox < StandardError; end

      def initialize(path, provider:)
        @path = path
        @provider = provider
      end

      def extract(destination)
        yield "/usr/bin/tar", "-xf", @path, "-C", destination, "--no-same-owner", "--no-same-permissions"
        metadata_path = File.join(destination, "metadata.json")
        unless File.file?(metadata_path) && !File.symlink?(metadata_path)
          raise InvalidBox, "Box is missing a regular metadata.json file: #{@path}"
        end

        metadata = JSON.parse(File.read(metadata_path))
        unless metadata.is_a?(Hash) && metadata["provider"] == @provider
          raise InvalidBox, "Box metadata must specify the #{@provider} provider: #{@path}"
        end

        metadata
      rescue JSON::ParserError => e
        raise InvalidBox, "Invalid metadata.json in #{@path}: #{e.message}"
      end
    end
  end
end

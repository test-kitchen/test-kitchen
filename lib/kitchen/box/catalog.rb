# Copyright 2026 Dan Webb
# SPDX-License-Identifier: Apache-2.0

require "digest" unless defined?(Digest)
require "json" unless defined?(JSON)
require "rbconfig" unless defined?(RbConfig)
require "kitchen/errors"
require_relative "remote_archive"

module Kitchen
  module Box
    class Catalog
      IDENTITY = %w{name version provider architecture}.freeze
      FIELDS = (IDENTITY + %w{file bytes sha256 url}).freeze
      ENV_KEY = "KITCHEN_BOX_MANIFEST".freeze

      attr_reader :directory

      def self.host_architecture
        case RbConfig::CONFIG.fetch("host_cpu")
        when "aarch64", "arm64" then "arm64"
        when "x86_64", "amd64" then "amd64"
        else RbConfig::CONFIG.fetch("host_cpu")
        end
      end

      def initialize(manifest)
        raise UserError, "Specify a box manifest with --manifest or #{ENV_KEY}" if manifest.to_s.empty?

        @manifest = File.realpath(manifest)
        @directory = File.dirname(@manifest)
        records = JSON.parse(File.read(@manifest))
        raise UserError, "Box manifest must contain an array: #{@manifest}" unless records.is_a?(Array)

        @entries = records.map.with_index(1) { |record, index| parse_entry(record, index) }
        keys = @entries.map { |entry| entry.values_at(*IDENTITY) }
        raise UserError, "Duplicate name, version, provider and architecture in #{@manifest}" unless keys.uniq.size == keys.size
      rescue JSON::ParserError, SystemCallError, IOError => e
        raise UserError, "Cannot read box manifest #{manifest}: #{e.message}"
      end

      def entries(name: nil, version: nil, provider: nil, architecture: nil)
        filters = { "name" => name, "version" => version, "provider" => provider, "architecture" => architecture }.compact
        @entries.select { |entry| filters.all? { |key, value| entry[key] == value } }
      end

      def resolve(name:, version:, provider:, architecture: self.class.host_architecture)
        verify(find(name: name, version: version, provider: provider, architecture: architecture), checksum: true)
      end

      def find(name:, version:, provider:, architecture: self.class.host_architecture)
        unless [name, version, provider, architecture].all? { |value| value.is_a?(String) && !value.empty? }
          raise UserError, "Box resolution requires a name, exact version, provider and architecture"
        end

        entry = entries(name: name, version: version, provider: provider, architecture: architecture).first
        unless entry
          raise UserError, "No box matches #{name} #{version} (#{provider}/#{architecture}) in #{@manifest}"
        end

        entry
      end

      def verify(entry, checksum: false)
        raise UserError, "A remote box must be downloaded before it can be used as a local archive" if entry.key?("url")

        path = File.realpath(File.join(directory, entry.fetch("file")))
        unless path.start_with?("#{directory.delete_suffix(File::SEPARATOR)}#{File::SEPARATOR}") && File.file?(path) && File.readable?(path)
          raise UserError, "Box must be a regular file inside the manifest directory: #{entry.fetch("file")}"
        end
        raise UserError, "Size mismatch for #{path}" unless File.size(path) == entry.fetch("bytes")
        if checksum && Digest::SHA256.file(path).hexdigest != entry.fetch("sha256")
          raise UserError, "SHA-256 mismatch for #{path}"
        end

        path
      rescue SystemCallError, IOError => e
        raise UserError, "Cannot read box #{entry.fetch("file")}: #{e.message}"
      end

      def copy_archive(entry, destination)
        if entry.key?("url")
          RemoteArchive.new(entry.fetch("url")).download(destination, bytes: entry.fetch("bytes"))
        else
          File.copy_stream(verify(entry), destination)
        end
      end

      private

      def parse_entry(record, index)
        unless record.is_a?(Hash) && (IDENTITY + %w{sha256}).all? { |key| record[key].is_a?(String) && !record[key].empty? } &&
            record["bytes"].is_a?(Integer) && record["bytes"] > 0 &&
            /\A[0-9a-f]{64}\z/i.match?(record["sha256"]) &&
            valid_archive?(record)
          raise UserError, "Invalid box manifest entry #{index} in #{@manifest}"
        end

        entry = record.slice(*FIELDS)
        entry["sha256"] = entry["sha256"].downcase
        entry.transform_values(&:freeze).freeze
      end

      def valid_archive?(record)
        if record.key?("url")
          !record.key?("file") && RemoteArchive.valid_url?(record["url"])
        else
          record["file"].is_a?(String) && record["file"].match?(%r{\A[^/\\:\x00]+\.box\z})
        end
      end
    end
  end
end

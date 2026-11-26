# Copyright 2026 Dan Webb
# SPDX-License-Identifier: Apache-2.0

require "digest" unless defined?(Digest::SHA256)
require "fileutils" unless defined?(FileUtils)
require "json" unless defined?(JSON)
require "tmpdir" unless defined?(Dir.mktmpdir)
require "securerandom" unless defined?(SecureRandom)
require "kitchen/errors"

module Kitchen
  module Box
    # Stores verified archive copies. Drivers keep a lease until destroy, including
    # after partial creation, so a prune plan can account for in-flight work.
    class Cache
      ENV_KEY = "KITCHEN_BOX_CACHE".freeze
      DIGEST = /\A[0-9a-f]{64}\z/
      TOKEN = /\A[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}\z/

      attr_reader :root

      def initialize(path = nil)
        @root = File.expand_path(path || ENV[ENV_KEY] || "~/.cache/test-kitchen/boxes")
      end

      def fetch(catalog, entry, token)
        digest = entry.fetch("sha256")
        validate_token(token)
        directory = entry_path(digest)
        validate_location(catalog.directory)
        FileUtils.mkdir_p(root, mode: 0o700)
        create_directory(directory)

        with_lock(directory) do
          leases = File.join(directory, "leases")
          create_directory(leases)
          File.write(File.join(leases, token), "", mode: "a", perm: 0o600)
          archive = File.join(directory, "archive.box")
          populate(directory, catalog, entry) unless verified?(archive, entry)
          archive
        end
      rescue SystemCallError, IOError => e
        raise UserError, "Cannot cache box in #{root}: #{e.message}"
      end

      def release(digest, token)
        validate_token(token)
        directory = entry_path(digest)
        return unless File.directory?(directory) && !File.symlink?(directory)

        with_lock(directory) do
          leases = File.join(directory, "leases")
          return unless File.directory?(leases) && !File.symlink?(leases)

          FileUtils.rm_f(File.join(leases, token))
        end
      rescue SystemCallError, IOError => e
        raise UserError, "Cannot release cached box in #{root}: #{e.message}"
      end

      def prune_plan(**filters)
        return { removable: [], protected: [], reclaimable_bytes: 0 } unless File.directory?(root) && !File.symlink?(root)

        removable = []
        protected = []
        Dir.children(root).sort.each do |digest|
          next unless DIGEST.match?(digest)

          candidate, reason = inspect_entry(digest)
          next unless candidate
          next unless filters.all? { |key, value| candidate[key] == value }

          if reason
            protected << candidate.merge(reason: reason)
          else
            removable << candidate
          end
        end
        { removable: removable, protected: protected, reclaimable_bytes: removable.sum { |row| row.fetch(:bytes) } }
      rescue SystemCallError, IOError => e
        raise UserError, "Cannot inspect box cache #{root}: #{e.message}"
      end

      private

      def validate_location(source_directory)
        existing = root
        existing = File.dirname(existing) until File.exist?(existing)
        actual_root = File.join(File.realpath(existing), root.delete_prefix(existing).sub(%r{\A/}, ""))
        source_prefix = source_directory.delete_suffix("/") + "/"
        if File.symlink?(root) || actual_root.delete_suffix("/") == source_directory || actual_root.start_with?(source_prefix)
          raise UserError, "Keep the local box cache outside the manifest directory"
        end
      end

      def validate_token(token)
        raise UserError, "Invalid box cache lease ID" unless TOKEN.match?(token.to_s)
      end

      def entry_path(digest)
        raise UserError, "Invalid box cache digest" unless DIGEST.match?(digest.to_s)

        File.join(root, digest)
      end

      def create_directory(path)
        Dir.mkdir(path, 0o700)
      rescue Errno::EEXIST
        raise UserError, "Invalid box cache directory: #{path}" unless File.directory?(path) && !File.symlink?(path)
      end

      def with_lock(directory)
        lock = File.join(directory, "lock")
        raise UserError, "Invalid box cache lock: #{lock}" if File.symlink?(lock)

        File.open(lock, File::RDWR | File::CREAT, 0o600) do |file|
          file.flock(File::LOCK_EX)
          yield
        end
      end

      def regular_file?(path)
        File.file?(path) && !File.symlink?(path)
      end

      def verified?(path, entry)
        regular_file?(path) && File.size(path) == entry.fetch("bytes") &&
          Digest::SHA256.file(path).hexdigest == entry.fetch("sha256")
      end

      def populate(directory, catalog, entry)
        source = catalog.verify(entry)
        Dir.mktmpdir("download-", directory) do |staging|
          archive = File.join(staging, "archive.box")
          File.copy_stream(source, archive)
          raise UserError, "SHA-256 or size mismatch while caching #{source}" unless verified?(archive, entry)

          metadata = File.join(staging, "metadata.json")
          File.write(metadata, JSON.generate(entry))
          File.rename(metadata, File.join(directory, "metadata.json"))
          File.rename(archive, File.join(directory, "archive.box"))
        end
      end

      def inspect_entry(digest)
        directory = entry_path(digest)
        archive = File.join(directory, "archive.box")
        metadata = File.join(directory, "metadata.json")
        lock = File.join(directory, "lock")
        return unless File.directory?(directory) && !File.symlink?(directory) &&
          [archive, metadata, lock].all? { |path| regular_file?(path) }

        File.open(lock, "rb") do |file|
          locked = file.flock(File::LOCK_SH | File::LOCK_NB)
          entry = JSON.parse(File.read(metadata))
          next unless entry.is_a?(Hash) && entry["sha256"] == digest

          stat = File.stat(archive)
          row = { sha256: digest, name: entry["name"], version: entry["version"],
                  provider: entry["provider"], architecture: entry["architecture"], path: archive, bytes: stat.size }
          leases = File.join(directory, "leases")
          reason = if !locked
                     "cache operation in progress"
                   elsif !File.directory?(leases) || File.symlink?(leases)
                     "lease directory unavailable"
                   elsif !Dir.empty?(leases)
                     "in use by a Kitchen instance"
                   elsif stat.nlink > 1
                     "archive has another hard link"
                   end
          [row, reason]
        end
      rescue Errno::ENOENT, JSON::ParserError
        nil
      end
    end
  end
end

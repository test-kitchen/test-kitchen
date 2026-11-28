# Copyright 2026 Dan Webb
# SPDX-License-Identifier: Apache-2.0

require "digest" unless defined?(Digest::SHA256)
require "fileutils" unless defined?(FileUtils)
require "json" unless defined?(JSON)
require "tmpdir" unless defined?(Dir.mktmpdir)
require "securerandom" unless defined?(SecureRandom)
require "kitchen/errors"
require_relative "catalog"

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

      def validate_destination(catalog, entry)
        validate_location(entry_path(entry.fetch("sha256")), catalog.directory)
      rescue SystemCallError, IOError => e
        raise UserError, "Cannot inspect box cache destination in #{root}: #{e.message}"
      end

      def fetch(catalog, entry, token)
        digest = entry.fetch("sha256")
        validate_token(token)
        directory = entry_path(digest)
        validate_location(directory, catalog.directory)
        FileUtils.mkdir_p(root, mode: 0o700)
        create_directory(directory)

        with_lock(directory) do
          leases = File.join(directory, "leases")
          create_directory(leases)
          create_lease(File.join(leases, token))
          archive = File.join(directory, "archive.box")
          populate(directory, catalog, entry) unless verified?(archive, entry)
          remember_identity(directory, entry)
          archive
        end
      rescue SystemCallError, IOError => e
        raise UserError, "Cannot cache box in #{root}: #{e.message}"
      end

      def release(digest, token)
        validate_token(token)
        directory = entry_path(digest)
        raise UserError, "Invalid box cache directory: #{root}" if File.symlink?(root)
        return unless existing_directory?(directory)

        leases = File.join(directory, "leases")
        return unless existing_directory?(leases)

        with_lock(directory, create: false) do
          remove_lease(File.join(leases, token))
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

          candidate, reason = inspect_entry(digest, filters)
          next unless candidate

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

      def validate_location(directory, source_directory)
        actual_root = physical_path(root)
        destination = physical_path(directory)
        if File.symlink?(root) || within_directory?(actual_root, source_directory) ||
            within_directory?(destination, source_directory) || within_directory?(source_directory, destination)
          raise UserError, "Keep the local box cache outside the manifest directory"
        end
      end

      def physical_path(path)
        parent = path
        parent = File.dirname(parent) until File.exist?(parent)
        File.join(File.realpath(parent), path.delete_prefix(parent).sub(%r{\A/}, ""))
      end

      def within_directory?(path, directory)
        loop do
          return true if File.identical?(path, directory)

          parent = File.dirname(path)
          return false if parent == path

          path = parent
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
        existing_directory?(path)
      end

      def existing_directory?(path)
        stat = File.lstat(path)
        raise UserError, "Invalid box cache directory: #{path}" unless stat.directory?

        true
      rescue Errno::ENOENT
        false
      end

      def create_lease(path)
        raise UserError, "Invalid box cache lease: #{path}" if File.symlink?(path)

        File.open(path, File::WRONLY | File::CREAT | File::EXCL, 0o600) {}
      rescue Errno::EEXIST
        raise UserError, "Invalid box cache lease: #{path}" unless regular_file?(path)
      end

      def remove_lease(path)
        File.unlink(path)
      rescue Errno::ENOENT
        nil
      end

      def with_lock(directory, create: true)
        lock = File.join(directory, "lock")
        raise UserError, "Invalid box cache lock: #{lock}" if File.symlink?(lock)

        flags = create ? File::RDWR | File::CREAT : File::RDWR
        File.open(lock, flags, 0o600) do |file|
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
        Dir.mktmpdir("download-", directory) do |staging|
          archive = File.join(staging, "archive.box")
          catalog.copy_archive(entry, archive)
          unless verified?(archive, entry)
            raise UserError, "SHA-256 or size mismatch while caching #{entry.values_at(*Catalog::IDENTITY).join(" ")}"
          end

          File.rename(archive, File.join(directory, "archive.box"))
        end
      end

      def remember_identity(directory, entry)
        digest = entry.fetch("sha256")
        metadata = File.join(directory, "metadata.json")
        identities = cached_identities(metadata, digest)
        identity = entry.slice(*Catalog::IDENTITY)
        return if identities.include?(identity)

        Dir.mktmpdir("metadata-", directory) do |staging|
          update = File.join(staging, "metadata.json")
          File.write(update, JSON.generate(sha256: digest, identities: identities + [identity]))
          File.rename(update, metadata)
        end
      end

      def cached_identities(path, digest)
        return [] unless regular_file?(path)

        metadata = JSON.parse(File.read(path))
        return [] unless metadata.is_a?(Hash) && metadata["sha256"] == digest

        identities = metadata.fetch("identities") { [metadata.slice(*Catalog::IDENTITY)] }
        return [] unless identities.is_a?(Array)

        identities.select { |identity| identity.is_a?(Hash) && Catalog::IDENTITY.all? { |key| identity[key].is_a?(String) } }
      rescue JSON::ParserError
        []
      end

      def inspect_entry(digest, filters)
        directory = entry_path(digest)
        archive = File.join(directory, "archive.box")
        metadata = File.join(directory, "metadata.json")
        lock = File.join(directory, "lock")
        return unless File.directory?(directory) && !File.symlink?(directory) &&
          [archive, metadata, lock].all? { |path| regular_file?(path) }

        File.open(lock, "rb") do |file|
          locked = file.flock(File::LOCK_SH | File::LOCK_NB)
          entry = cached_identities(metadata, digest).find { |identity| filters.all? { |key, value| identity[key.to_s] == value } }
          next unless entry

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
      rescue Errno::ENOENT
        nil
      end
    end
  end
end

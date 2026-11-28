# Copyright 2026 Dan Webb
# SPDX-License-Identifier: Apache-2.0

require "thor" unless defined?(Thor)
require "tmpdir" unless defined?(Dir.mktmpdir)
require_relative "catalog"
require_relative "cache"

module Kitchen
  module Box
    class CLI < Thor
      class_option :manifest, type: :string, desc: "Path to the box manifest (or KITCHEN_BOX_MANIFEST)"
      class_option :name, type: :string, desc: "Filter by exact box name"
      class_option :version, type: :string, desc: "Filter by exact box version"
      class_option :provider, type: :string, desc: "Filter by provider"
      class_option :architecture, type: :string, desc: "Filter by architecture"
      class_option :json, type: :boolean, aliases: "-j", desc: "Print JSON"

      def self.exit_on_failure?
        true
      end

      desc "list", "List boxes from the manifest"
      def list
        entries = selected_entries(catalog).map do |entry|
          entry.key?("url") ? entry.merge("url" => display_url(entry)) : entry
        end
        if options[:json]
          puts JSON.pretty_generate(entries)
        else
          rows = entries.map { |entry| entry.values_at(*Catalog::IDENTITY) + [entry["file"] || entry["url"], entry["bytes"]] }
          print_table([%w{Name Version Provider Architecture Source Bytes}, *rows])
        end
      end

      desc "doctor", "Check local archives and optionally verify remote archives"
      option :checksum, type: :boolean, desc: "Verify SHA-256, downloading selected remote archives"
      def doctor
        source = catalog
        entries = selected_entries(source)
        raise UserError, "No boxes match the selected filters" if entries.empty?

        results = entries.map { |entry| check_entry(source, entry) }
        if options[:json]
          puts JSON.pretty_generate(results)
        else
          results.each do |entry|
            status = entry[:error] ? "FAIL" : entry[:status] || "OK"
            puts "#{status}  #{entry[:file] || entry[:url]}#{entry[:error] && "  #{entry[:error]}"}"
          end
        end
        exit 1 if results.any? { |entry| entry[:error] }
      end

      desc "prune --dry-run", "Show unused local archives and how much space they occupy"
      option :dry_run, type: :boolean, desc: "Preview without changing the cache"
      option :cache, type: :string, desc: "Cache directory (or KITCHEN_BOX_CACHE)"
      def prune
        raise UserError, "Use kitchen box prune --dry-run to preview cache cleanup" unless options[:dry_run]

        cache = Cache.new(options[:cache])
        plan = cache.prune_plan(**filters)
        if options[:json]
          puts JSON.pretty_generate(plan.merge(cache: cache.root, dry_run: true))
        else
          puts "Dry run for #{cache.root}"
          plan.fetch(:removable).each { |row| puts "Would remove  #{box_label(row)}  (#{row.fetch(:bytes)} bytes)\n              #{row.fetch(:path)}" }
          plan.fetch(:protected).each { |row| puts "Keep          #{box_label(row)}  (#{row.fetch(:reason)})" }
          bytes = plan.fetch(:reclaimable_bytes)
          puts "#{plan.fetch(:removable).size} archive(s), #{bytes} bytes reclaimable (#{format("%.2f", bytes.fdiv(1024**2))} MiB)"
        end
      end

      private

      def catalog
        Catalog.new(options[:manifest] || ENV[Catalog::ENV_KEY])
      end

      def selected_entries(source)
        source.entries(**filters)
      end

      def filters
        { name: options[:name], version: options[:version], provider: options[:provider], architecture: options[:architecture] }.compact
      end

      def box_label(row)
        "#{row[:name]} #{row[:version]} (#{row[:provider]}/#{row[:architecture]})"
      end

      def check_entry(source, entry)
        location = entry.key?("url") ? { url: display_url(entry) } : { file: entry.fetch("file") }
        if entry.key?("url")
          return location.merge(status: "SKIP (use --checksum)", checksum_verified: false) unless options[:checksum]

          Dir.mktmpdir("kitchen-box-doctor-") do |directory|
            archive = File.join(directory, "archive.box")
            source.stage_verified_archive(entry, archive, mismatch: "SHA-256 or size mismatch for remote box")
          end
          return location.merge(checksum_verified: true)
        end

        path = source.verify(entry, checksum: options[:checksum])
        location.merge(path: path, checksum_verified: !!options[:checksum])
      rescue UserError => e
        location.merge(error: e.message)
      end

      def display_url(entry)
        URI.parse(entry.fetch("url")).tap { |uri| uri.query = nil }.to_s
      end
    end
  end
end

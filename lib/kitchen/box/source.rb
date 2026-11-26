# Copyright 2026 Dan Webb
# SPDX-License-Identifier: Apache-2.0

require_relative "catalog"
require_relative "cache"

module Kitchen
  module Box
    module Source
      private

      def box_source(provider, state)
        box = config[:box]
        return File.expand_path(box, config[:kitchen_root]) if box.is_a?(String)

        unless box.is_a?(Hash) && %i{name version}.all? { |key| box[key].is_a?(String) && !box[key].empty? }
          raise ActionFailed, "Set driver.box to a local path or a map with name and an exact version"
        end

        manifest = config[:box_manifest] || ENV[Catalog::ENV_KEY]
        manifest = File.expand_path(manifest, config[:kitchen_root]) unless manifest.to_s.empty?
        source = Catalog.new(manifest)
        entry = source.find(name: box[:name], version: box[:version], provider: provider)
        cache = Cache.new(config[:box_cache])
        reference = state[:box_cache_lease]
        if reference && (reference[:root] != cache.root || reference[:digest] != entry.fetch("sha256"))
          raise ActionFailed, "Run kitchen destroy before changing the cached box or cache location for this instance"
        end

        unless reference
          cache.validate_destination(source, entry)
          reference = { root: cache.root, digest: entry.fetch("sha256"), token: SecureRandom.uuid }
          state[:box_cache_lease] = reference
          yield
        end
        cache.fetch(source, entry, reference.fetch(:token))
      rescue UserError => e
        raise ActionFailed, e.message
      end

      def release_box_source(state)
        reference = state[:box_cache_lease]
        return unless reference

        Cache.new(reference.fetch(:root)).release(reference.fetch(:digest), reference.fetch(:token))
        state.delete(:box_cache_lease)
      rescue UserError => e
        raise ActionFailed, e.message
      end
    end
  end
end

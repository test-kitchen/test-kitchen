# frozen_string_literal: true

module KitchenDokkenCI
  def self.patch_helpers
    return unless defined?(::Dokken::Helpers)

    ::Dokken::Helpers.module_eval do
      def remote_docker_host?
        info = config[:docker_info] || {}
        operating_system = info['OperatingSystem'] || info[:OperatingSystem].to_s

        return false if operating_system.include?('Docker Desktop')
        return false if operating_system.include?('Boot2Docker')

        /^tcp:/.match?(config[:docker_host_url].to_s)
      end

      def running_inside_docker?
        return false if ENV['GITHUB_ACTIONS'] == 'true' && !remote_docker_host?

        File.file?('/.dockerenv')
      end
    end
  end
end

helper_patch = TracePoint.new(:end) do |trace|
  next unless defined?(::Dokken::Helpers) && trace.self.equal?(::Dokken::Helpers)

  KitchenDokkenCI.patch_helpers
  helper_patch.disable
end

helper_patch.enable
KitchenDokkenCI.patch_helpers

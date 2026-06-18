# frozen_string_literal: true

module KitchenDokkenCI
  def self.patch
    patch_helpers if defined?(::Dokken::Helpers)
    patch_provisioner if defined?(::Kitchen::Provisioner::Dokken)
  end

  def self.patch_helpers
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

  def self.patch_provisioner
    ::Kitchen::Provisioner::Dokken.class_eval do
      # rubocop:disable Chef/Deprecations/UsesRunCommandHelper
      def call(state)
        create_sandbox
        write_run_command(run_command)
        instance.transport.connection(state) do |conn|
          if dokken_data_container_upload?(state)
            info("Transferring files to #{instance.to_str}")
            conn.upload(sandbox_dirs, config[:root_path])
          end

          conn.execute(prepare_command)
          conn.execute_with_retry(
            "sh #{config[:root_path]}/run_command",
            config[:retry_on_exit_code],
            config[:max_retries],
            config[:wait_for_retry]
          )
        end
      rescue Kitchen::Transport::TransportFailed => ex
        raise ActionFailed, ex.message
      ensure
        cleanup_dokken_sandbox if config[:clean_dokken_sandbox]
      end
      # rubocop:enable Chef/Deprecations/UsesRunCommandHelper

      private

      def dokken_data_container_upload?(state)
        return false if ENV['GITHUB_ACTIONS'] == 'true' && !remote_docker_host?

        port = state.dig(:data_container, :NetworkSettings, :Ports, :"22/tcp")&.first

        (remote_docker_host? || running_inside_docker?) && port&.fetch(:HostPort, nil)
      end
    end
  end
end

dokken_patch = TracePoint.new(:end) do |trace|
  if defined?(::Dokken::Helpers) && trace.self.equal?(::Dokken::Helpers)
    KitchenDokkenCI.patch
  elsif defined?(::Kitchen::Provisioner::Dokken) && trace.self.equal?(::Kitchen::Provisioner::Dokken)
    KitchenDokkenCI.patch
    dokken_patch.disable
  end
end

dokken_patch.enable
KitchenDokkenCI.patch

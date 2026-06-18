# frozen_string_literal: true

require 'kitchen/provisioner/dokken'
require 'kitchen/provisioner/cinc/berkshelf'
require 'kitchen/provisioner/cinc/common_sandbox'
require 'kitchen/provisioner/cinc/policyfile'

module KitchenDokkenCI
  def self.patch
    ::Dokken::Helpers.prepend(HelperPatch)
    ::Kitchen::Provisioner::Dokken.prepend(ProvisionerPatch)
    ::Kitchen::Verifier::Base.prepend(VerifierPatch)
  end

  module HelperPatch
    def remote_docker_host?
      false
    end

    def running_inside_docker?
      false
    end
  end

  module ProvisionerPatch
    def create_sandbox
      ::Kitchen::Provisioner::Base.instance_method(:create_sandbox).bind_call(self)
      sanity_check_sandbox_options!
      ::Kitchen::Provisioner::Cinc::CommonSandbox.new(config, sandbox_path, instance).populate
      prepare_validation_pem
      prepare_config_rb
    end

    def load_needed_dependencies!
      if File.exist?(policyfile)
        debug("Policyfile found at #{policyfile}, using Cinc Policyfile to resolve cookbook dependencies")
        ::Kitchen::Provisioner::Cinc::Policyfile.load!(logger:)
      elsif File.exist?(berksfile)
        debug("Berksfile found at #{berksfile}, using Cinc Berkshelf to resolve cookbook dependencies")
        ::Kitchen::Provisioner::Cinc::Berkshelf.load!(logger:)
      end
    end

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
      raise ::Kitchen::ActionFailed, ex.message
    ensure
      cleanup_dokken_sandbox if config[:clean_dokken_sandbox]
    end
    # rubocop:enable Chef/Deprecations/UsesRunCommandHelper

    private

    def dokken_data_container_upload?(_state)
      false
    end
  end

  module VerifierPatch
    # rubocop:disable Chef/Deprecations/UsesRunCommandHelper
    def call(state)
      create_sandbox
      instance.transport.connection(state) do |conn|
        conn.execute(install_command)

        conn.execute(prepare_command)
        conn.execute(run_command)
      end
    rescue Kitchen::Transport::TransportFailed => ex
      raise ::Kitchen::ActionFailed, ex.message
    end
    # rubocop:enable Chef/Deprecations/UsesRunCommandHelper
  end
end

module Kitchen
  module Provisioner
    class DokkenCi < Dokken
      kitchen_provisioner_api_version 2

      plugin_version Kitchen::VERSION

      # Dokken inherits from ChefInfra, whose enterprise factory can return a
      # Cinc/ChefInfra instance. Bypass that factory so this CI subclass keeps
      # Dokken's converge behavior.
      def self.new(config = {})
        allocate.tap do |instance|
          instance.send(:initialize, config)
        end
      end
    end
  end
end

KitchenDokkenCI.patch

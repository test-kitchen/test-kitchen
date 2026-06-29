#
# Copyright:: (C) 2026
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "json" unless defined?(JSON)
require "open3"
require "rbconfig" unless defined?(RbConfig)
require "shellwords" unless defined?(Shellwords)

require_relative "base"
require_relative "../version"

module Kitchen
  module Provisioner
    # Executes an external provisioner provider over the v1 stdio protocol.
    class External < Base
      PROTOCOL_VERSION = "1.0".freeze
      RESULT_STATUSES = %w{passed failed skipped}.freeze
      LOG_LEVELS = %w{debug info warn error}.freeze
      INTERNAL_CONFIG_KEYS = %i{
        command provider pass_env kitchen_root test_base_path
      }.freeze
      REDACTED_KEYS = %w{password ssh_http_proxy_password}.freeze

      kitchen_provisioner_api_version 2

      plugin_version Kitchen::VERSION

      required_config :command

      default_config :provider, &:provider_name_from_command
      default_config :pass_env, []

      # (see Base#call)
      def call(state)
        verify_capabilities
        validate_provider(state)
        result = run_provider(state)
        persist_provider_state(state, result)
      end

      def provider_name_from_command
        first_part = Shellwords.split(config[:command].to_s).first.to_s
        File.basename(first_part).sub(/^kitchen-provider-/, "")
      end

      private

      def verify_capabilities
        response = invoke_json("capabilities", {})
        protocol_version = response.fetch("protocol_version", nil)
        unless protocol_version == PROTOCOL_VERSION
          raise_protocol_error(
            "Unsupported external provider protocol version #{protocol_version.inspect}"
          )
        end

        commands = Array(response["commands"])
        missing_commands = %w{validate run} - commands
        unless missing_commands.empty?
          raise_protocol_error(
            "External provider does not support required command(s): #{missing_commands.join(", ")}"
          )
        end

        transports = Array(response["supported_transports"])
        transport_type = transport_component({}).fetch(:type)
        return if transports.include?(transport_type)

        raise_protocol_error(
          "External provider does not support #{transport_type.inspect} transport"
        )
      end

      def validate_provider(state)
        response = invoke_json("validate", request_envelope("validate", state))
        require_protocol_version(response, "validation result")

        return if response["status"] == "ok"

        messages = Array(response["errors"]).map { |error| error["message"] }.compact
        message = messages.empty? ? "external provider validation failed" : messages.join("; ")
        raise ActionFailed, redact(message)
      end

      def run_provider(state)
        stdout, stderr, status = invoke("run", request_envelope("run", state))
        result = nil

        stdout.each_line.with_index(1) do |line, index|
          next if line.strip.empty?

          event = parse_event(line, index)
          require_protocol_version(event, "event")

          case event["type"]
          when "log"
            handle_log_event(event)
          when "progress"
            handle_progress_event(event)
          when "result"
            result = event
          else
            raise_protocol_error("unknown external provider event type #{event["type"].inspect}")
          end
        end

        unless status.success?
          raise_protocol_error("external provider exited with #{status.exitstatus}", stderr)
        end
        raise_protocol_error("external provider did not emit a final result") if result.nil?

        handle_result_event(result)
        result
      end

      def handle_log_event(event)
        level = event["level"]
        raise_protocol_error("external provider log event has invalid level #{level.inspect}") unless LOG_LEVELS.include?(level)

        logger.public_send(level, redact(event.fetch("message", "")))
      end

      def handle_progress_event(event)
        stage = event.fetch("stage", "provider")
        message = event.fetch("message", "")
        info(redact("[#{stage}] #{message}"))
      end

      def handle_result_event(event)
        status = event["status"]
        unless RESULT_STATUSES.include?(status)
          raise_protocol_error("external provider result has invalid status #{status.inspect}")
        end

        return if %w{passed skipped}.include?(status)

        message = event["message"] || "external provider reported #{status}"
        raise ActionFailed, redact(message)
      end

      def persist_provider_state(state, result)
        provider_state = result.dig("state", "provider")
        return if provider_state.nil?

        state[:providers] ||= {}
        state[:providers][config[:provider]] = provider_state
      end

      def invoke_json(operation, request)
        stdout, stderr, status = invoke(operation, request)
        unless status.success?
          raise_protocol_error("external provider #{operation} exited with #{status.exitstatus}", stderr)
        end

        JSON.parse(stdout)
      rescue JSON::ParserError => error
        raise_protocol_error("malformed external provider #{operation} response: #{error.message}")
      end

      def invoke(operation, request)
        Open3.capture3(
          provider_environment,
          *provider_command_parts,
          operation,
          stdin_data: JSON.generate(request)
        )
      rescue Errno::ENOENT => error
        raise ActionFailed, redact("external provider command failed: #{error.message}")
      end

      def provider_command_parts
        parts = Shellwords.split(config[:command].to_s)
        raise ActionFailed, "external provider command cannot be blank" if parts.empty?

        parts
      end

      def provider_environment
        pass_env.each_with_object({}) do |name, env|
          env[name] = ENV[name] if ENV.key?(name)
        end
      end

      def request_envelope(operation, state)
        {
          protocol_version: PROTOCOL_VERSION,
          operation: operation,
          kitchen: kitchen_context,
          instance: instance_context(state),
          platform: platform_context,
          suite: suite_context,
          components: components_context(state),
          executor: executor_context,
          environment: environment_context,
          state: state_context(state),
        }
      end

      def kitchen_context
        {
          version: Kitchen::VERSION,
          root_path: File.expand_path(config[:kitchen_root] || Dir.pwd),
        }
      end

      def instance_context(state)
        {
          name: instance.name,
          last_action: state[:last_action],
          last_attempted_action: state[:last_attempted_action],
        }
      end

      def platform_context
        {
          name: component_name(instance.platform),
          os_type: component_attr(instance.platform, :os_type),
          shell_type: component_attr(instance.platform, :shell_type),
        }
      end

      def suite_context
        { name: instance.suite.name }
      end

      def components_context(state)
        {
          driver: resolved_component(instance.driver, {}),
          transport: transport_component(state),
          provisioner: {
            name: "external",
            provider: config[:provider],
            command: config[:command],
            config: provider_config,
          },
          verifier: resolved_component(instance.verifier, {}),
        }
      end

      def resolved_component(component, state)
        {
          name: component_name(component),
          config: {},
          state: state,
        }
      end

      def transport_component(state)
        name = component_name(instance.transport)
        type = transport_type(name)
        base = {
          name: name,
          type: type,
          config: {},
        }

        case type
        when "exec"
          base.merge(
            target: { kind: "local", platform: component_attr(instance.platform, :name) },
            config: {
              kitchen_root: File.expand_path(config[:kitchen_root] || Dir.pwd),
              host_os: RbConfig::CONFIG["host_os"],
            }
          )
        when "ssh"
          base.merge(
            target: machine_target(state),
            config: compact_hash(
              username: component_config(:username, state, "root"),
              port: component_config(:port, state, 22),
              connection_timeout: component_config(:connection_timeout, state),
              connection_retries: component_config(:connection_retries, state),
              connection_retry_sleep: component_config(:connection_retry_sleep, state),
              proxy_command: component_config(:ssh_proxy_command, state),
              gateway: component_config(:ssh_gateway, state),
              gateway_port: component_config(:ssh_gateway_port, state),
              gateway_username: component_config(:ssh_gateway_username, state)
            )
          )
        when "winrm"
          base.merge(
            target: machine_target(state),
            config: compact_hash(
              username: component_config(:username, state, "administrator"),
              port: component_config(:port, state, 5985),
              scheme: component_config(:scheme, state, "http"),
              transport: component_config(:winrm_transport, state, "negotiate").to_s,
              elevated: component_config(:elevated, state),
              operation_timeout: component_config(:operation_timeout, state),
              receive_timeout: component_config(:receive_timeout, state),
              connection_retries: component_config(:connection_retries, state),
              connection_retry_sleep: component_config(:connection_retry_sleep, state)
            )
          )
        else
          base.merge(target: { kind: "custom" })
        end
      end

      def transport_type(name)
        case name.to_s
        when "ssh", "winrm", "exec", "docker_exec"
          name.to_s
        else
          "custom"
        end
      end

      def executor_context
        {
          model: "exec",
          command: config[:command],
          input: "stdin",
          request_file_argument: nil,
          event_stream: "ndjson",
        }
      end

      def environment_context
        passed = pass_env.select { |name| ENV.key?(name) }
        {
          passed: passed,
          user_allowed: pass_env,
          kitchen_reserved: [],
        }
      end

      def state_context(state)
        providers = state.fetch(:providers, {})
        { provider: providers.fetch(config[:provider], {}) }
      end

      def machine_target(state)
        {
          kind: "machine",
          hostname: state.fetch(:hostname, state.fetch("hostname", "unknown")),
          platform: component_attr(instance.platform, :name),
        }
      end

      def component_config(key, state, default = nil)
        return state[key] if state.key?(key)
        return state[key.to_s] if state.key?(key.to_s)
        return instance.transport[key] if instance.transport.respond_to?(:[]) && !instance.transport[key].nil?

        default
      end

      def compact_hash(hash)
        hash.compact
      end

      def provider_config
        config.each_with_object({}) do |(key, value), result|
          next if INTERNAL_CONFIG_KEYS.include?(key)

          result[key.to_s] = value
        end
      end

      def pass_env
        Array(config[:pass_env]).map(&:to_s)
      end

      def component_name(component)
        return component.name if component.respond_to?(:name)

        component.class.name.split("::").last.downcase
      end

      def component_attr(component, attr)
        component.public_send(attr) if component.respond_to?(attr)
      end

      def parse_event(line, index)
        JSON.parse(line)
      rescue JSON::ParserError => error
        raise_protocol_error(
          "malformed external provider event at line #{index}: #{error.message}"
        )
      end

      def require_protocol_version(payload, payload_type)
        return if payload["protocol_version"] == PROTOCOL_VERSION

        raise_protocol_error(
          "external provider #{payload_type} used unsupported protocol version #{payload["protocol_version"].inspect}"
        )
      end

      def raise_protocol_error(message, stderr = nil)
        details = [message]
        details << stderr.to_s.strip unless stderr.to_s.strip.empty?
        raise ActionFailed, redact(details.join(": "))
      end

      def redact(message)
        redacted = Util.mask_values(message.to_s.dup, REDACTED_KEYS)
        pass_env.each do |name|
          value = ENV[name].to_s
          redacted.gsub!(value, "******") unless value.empty?
        end
        redacted
      end
    end
  end
end

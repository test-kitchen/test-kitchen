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

require "json"

MODE = ARGV.fetch(0)
OPERATION = ARGV.fetch(1)

def read_request
  input = $stdin.read
  request = input.empty? ? {} : JSON.parse(input)

  if ENV["FAKE_EXTERNAL_PROVIDER_REQUEST_LOG"]
    File.open(ENV.fetch("FAKE_EXTERNAL_PROVIDER_REQUEST_LOG"), "a") do |file|
      file.puts(JSON.generate(request))
    end
  end

  request
end

def capabilities(protocol_version: "1.0")
  supported_transports = if MODE == "all_transports"
                           %w{ssh winrm exec docker_exec custom}
                         else
                           %w{exec}
                         end

  {
    protocol_version: protocol_version,
    provider: {
      name: "fake",
      type: "provisioner",
      version: "0.1.0",
    },
    execution_model: "exec",
    channel: "stdio",
    commands: %w{validate run},
    event_stream: "ndjson",
    supported_transports: supported_transports,
    secret_policy: {
      json_contains_secret_values: false,
      secret_delivery: "environment",
      environment_variables: "allowlist",
    },
  }
end

def validation(status, message = nil)
  response = { protocol_version: "1.0", status: status }
  response[:errors] = [{ code: "invalid", message: message }] if message
  response
end

def event(payload)
  $stdout.puts(JSON.generate({ protocol_version: "1.0" }.merge(payload)))
end

case OPERATION
when "capabilities"
  read_request
  if MODE == "unsupported_protocol"
    puts JSON.generate(capabilities(protocol_version: "2.0"))
  else
    puts JSON.generate(capabilities)
  end
when "validate"
  read_request
  if MODE == "validation_error"
    puts JSON.generate(validation("error", "suite is not valid for fake provider"))
  else
    puts JSON.generate(validation("ok"))
  end
when "run"
  read_request

  case MODE
  when "converge_failure"
    event(type: "result", status: "failed", message: "fake converge failed", exit_code: 42)
  when "malformed_json"
    puts("{not-json")
  when "missing_result"
    event(type: "log", level: "info", message: "started without finishing")
  when "non_zero"
    warn("provider process exploded")
    exit 17
  when "noisy_stderr"
    warn("debug detail on stderr")
    event(type: "result", status: "passed", state: { provider: { instance_id: "abc-123" } })
  when "secret_echo"
    event(type: "log", level: "info", message: "secret is #{ENV.fetch("TK_FAKE_SECRET", "")}")
    event(type: "result", status: "failed", message: "failed with #{ENV.fetch("TK_FAKE_SECRET", "")}")
  else
    event(type: "log", level: "info", message: "installing fake provider")
    event(type: "progress", stage: "converge", message: "halfway through fake run")
    event(type: "result", status: "passed", state: { provider: { instance_id: "abc-123" } })
  end
else
  warn("unknown operation: #{OPERATION}")
  exit 64
end

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

require_relative '../../spec_helper'

require 'json'

require 'kitchen'
require 'kitchen/collection'
require 'kitchen/command/list'

describe Kitchen::Command::List do
  let(:component) { stub(name: 'Dummy') }
  let(:instance) do
    stub(
      name: 'default-ubuntu-2404',
      driver: component,
      provisioner: component,
      verifier: component,
      transport: component,
      last_action: 'create',
      last_error: nil,
      log_path: '.kitchen/logs/default-ubuntu-2404.log',
      structured_log_path: '.kitchen/logs/default-ubuntu-2404.ndjson',
      state_path: '.kitchen/default-ubuntu-2404.yml',
      current_session_id: 'session-123',
      status: {
        live: true,
        state: 'running',
        source: 'driver',
        resource_id: 'vm-123',
        checked_at: '2026-06-18T12:00:00Z',
      }
    )
  end
  let(:config) { stub(instances: Kitchen::Collection.new([instance])) }
  let(:shell) { stub }

  def list_output(options)
    command = Kitchen::Command::List.new(
      ['default-ubuntu-2404'],
      options,
      action: 'list',
      help: -> {},
      config:,
      shell:
    )
    stdout, = capture_io { command.call }
    JSON.parse(stdout).fetch(0)
  end

  it 'keeps default JSON output compatible' do
    data = list_output(json: true)

    _(data.keys).must_equal %w(
      instance driver provisioner verifier transport last_action last_error
    )
  end

  it 'adds current log and liveness metadata with --live JSON output' do
    data = list_output(json: true, live: true)

    _(data['log_path']).must_equal '.kitchen/logs/default-ubuntu-2404.log'
    _(data['structured_log_path']).must_equal '.kitchen/logs/default-ubuntu-2404.ndjson'
    _(data['state_path']).must_equal '.kitchen/default-ubuntu-2404.yml'
    _(data['instance_session_id']).must_equal 'session-123'
    _(data['status']['live']).must_equal true
    _(data['status']['state']).must_equal 'running'
  end
end

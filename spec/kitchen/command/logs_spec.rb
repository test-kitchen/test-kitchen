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
require 'tmpdir'

require 'kitchen'
require 'kitchen/collection'
require 'kitchen/command/logs'

describe Kitchen::Command::Logs do
  let(:log_path) { File.join(log_dir, 'default-ubuntu-2404.ndjson') }
  let(:other_log_path) { File.join(log_dir, 'default-almalinux-9.ndjson') }
  let(:log_dir) { File.join(tmpdir, '.kitchen', 'logs') }
  let(:tmpdir) { Dir.mktmpdir }
  let(:instance) do
    stub(
      name: 'default-ubuntu-2404',
      to_str: '<default-ubuntu-2404>',
      structured_log_path: log_path,
      current_session_id: 'session-current'
    )
  end
  let(:other_instance) do
    stub(
      name: 'default-almalinux-9',
      to_str: '<default-almalinux-9>',
      structured_log_path: other_log_path,
      current_session_id: 'other-current'
    )
  end
  let(:config) { stub(instances: Kitchen::Collection.new([instance])) }
  let(:shell) { stub }
  let(:args) { ['default-ubuntu-2404'] }
  let(:options) { {} }
  let(:command) do
    Kitchen::Command::Logs.new(
      args,
      options,
      action: 'logs',
      help: -> {},
      config:,
      shell:
    )
  end

  after do
    FileUtils.remove_entry(tmpdir) if File.directory?(tmpdir)
  end

  def write_log_events(*events)
    FileUtils.mkdir_p(log_dir)
    File.write(log_path, events.map { |event| JSON.generate(event) }.join("\n") + "\n")
  end

  def write_other_log_events(*events)
    FileUtils.mkdir_p(log_dir)
    File.write(other_log_path, events.map { |event| JSON.generate(event) }.join("\n") + "\n")
  end

  def captured_events
    captured_lines.map { |line| JSON.parse(line) }
  end

  def captured_lines
    stdout, = capture_io { Dir.chdir(tmpdir) { command.call } }
    stdout.lines
  end

  def captured_messages
    stdout, = capture_io { Dir.chdir(tmpdir) { command.call } }
    stdout.lines.map(&:chomp)
  end

  it 'prints current-session text by default' do
    write_log_events(
      { instance_session_id: 'session-old', level: 'error', message: 'old' },
      { instance_session_id: 'session-current', level: 'info', message: 'current' }
    )

    messages = captured_messages

    _(messages).must_equal %w(current)
  end

  it 'prints current-session NDJSON when requested' do
    options[:format] = 'ndjson'
    write_log_events(
      { instance_session_id: 'session-old', level: 'error', message: 'old' },
      { instance_session_id: 'session-current', level: 'info', message: 'current' }
    )

    events = captured_events

    _(events.length).must_equal 1
    _(events.fetch(0)['message']).must_equal 'current'
  end

  it 'filters by minimum log level' do
    options[:format] = 'ndjson'
    options[:level] = 'warn'
    write_log_events(
      { instance_session_id: 'session-current', level: 'debug', message: 'debug' },
      { instance_session_id: 'session-current', level: 'info', message: 'info' },
      { instance_session_id: 'session-current', level: 'warn', message: 'warn' },
      { instance_session_id: 'session-current', level: 'error', message: 'error' }
    )

    events = captured_events

    _(events.map { |event| event['message'] }).must_equal %w(warn error)
  end

  it 'can print all sessions' do
    options[:format] = 'ndjson'
    options[:all_sessions] = true
    write_log_events(
      { instance_session_id: 'session-old', level: 'error', message: 'old' },
      { instance_session_id: 'session-current', level: 'info', message: 'current' }
    )

    events = captured_events

    _(events.map { |event| event['message'] }).must_equal %w(old current)
  end

  it 'falls back to the latest session in the log file when state is gone' do
    options[:format] = 'ndjson'
    instance.stubs(:current_session_id).returns(nil)
    write_log_events(
      { instance_session_id: 'session-old', level: 'error', message: 'old' },
      { instance_session_id: 'session-latest', level: 'info', message: 'latest' }
    )

    events = captured_events

    _(events.map { |event| event['message'] }).must_equal %w(latest)
  end

  describe 'with multiple instances' do
    let(:args) { [] }
    let(:config) { stub(instances: Kitchen::Collection.new([instance, other_instance])) }

    it 'can print all sessions for every instance when no instance is specified' do
      options[:format] = 'ndjson'
      options[:all_sessions] = true
      config.expects(:instances).never
      write_log_events(
        { instance: 'default-ubuntu-2404', instance_session_id: 'old', level: 'info', message: 'ubuntu' }
      )
      write_other_log_events(
        { instance: 'default-almalinux-9', instance_session_id: 'other', level: 'info', message: 'almalinux' }
      )

      events = captured_events

      _(events.map { |event| event['message'] }).must_equal %w(almalinux ubuntu)
    end

    it 'filters all-session logs from disk by instance name' do
      options[:format] = 'ndjson'
      options[:all_sessions] = true
      config.expects(:instances).never
      args << 'default-ubuntu-2404'
      write_log_events(
        { instance: 'default-ubuntu-2404', instance_session_id: 'old', level: 'info', message: 'ubuntu' }
      )
      write_other_log_events(
        { instance: 'default-almalinux-9', instance_session_id: 'other', level: 'info', message: 'almalinux' }
      )

      events = captured_events

      _(events.map { |event| event['message'] }).must_equal %w(ubuntu)
    end

    it 'rejects following more than one instance log' do
      options[:all_sessions] = true
      options[:follow] = true
      config.expects(:instances).never
      write_log_events(
        { instance: 'default-ubuntu-2404', instance_session_id: 'old', level: 'info', message: 'ubuntu' }
      )
      write_other_log_events(
        { instance: 'default-almalinux-9', instance_session_id: 'other', level: 'info', message: 'almalinux' }
      )
      command.expects(:follow_file).never

      _ { capture_io { Dir.chdir(tmpdir) { command.call } } }.must_raise SystemExit
    end
  end
end

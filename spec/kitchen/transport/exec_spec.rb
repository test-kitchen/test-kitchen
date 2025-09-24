#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative "../../spec_helper"

require "kitchen/transport/exec"

describe Kitchen::Transport::Exec do
  before do
    RbConfig::CONFIG.stubs(:[]).with("host_os").returns("blah")
  end

  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:config)        { {} }
  let(:state)         { {} }

  let(:instance) do
    stub(name: "coolbeans", logger: logger, to_str: "instance")
  end

  let(:transport) do
    Kitchen::Transport::Exec.new(config).finalize_config!(instance)
  end

  it "provisioner api_version is 1" do
    _(transport.diagnose_plugin[:api_version]).must_equal 1
  end

  it "plugin_version is set to Kitchen::VERSION" do
    _(transport.diagnose_plugin[:version]).must_equal Kitchen::VERSION
  end

  describe "#connection" do
    let(:klass) { Kitchen::Transport::Exec::Connection }

    def self.common_connection_specs
      before do
        config[:kitchen_root] = "/i/am/root"
      end

      it "returns a Kitchen::Transport::Exec::Connection object" do
        _(transport.connection(state)).must_be_kind_of klass
      end

      it "sets :instance_name to the instance's name" do
        klass.expects(:new).with do |hash|
          hash[:instance_name] == "coolbeans"
        end

        make_connection
      end

      it "sets :kitchen_root to the transport's kitchen_root" do
        klass.expects(:new).with do |hash|
          hash[:kitchen_root] == "/i/am/root"
        end

        make_connection
      end

      describe "called without a block" do
        def make_connection(s = state) # rubocop:disable Lint/NestedMethodDefinition
          transport.connection(s)
        end

        common_connection_specs
      end

      describe "called with a block" do
        def make_connection(s = state) # rubocop:disable Lint/NestedMethodDefinition
          transport.connection(s) do |conn|
            conn
          end
        end

        common_connection_specs
      end
    end
  end
end

describe Kitchen::Transport::Exec::Connection do
  before do
    RbConfig::CONFIG.stubs(:[]).with("host_os").returns("blah")
  end

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }
  let(:exec_script)     { File.join("/tmp/.kitchen/instance-exec-script.ps1") }

  let(:options) do
    { logger: logger }
  end

  let(:connection) do
    Kitchen::Transport::Exec::Connection.new(options)
  end

  describe "#execute" do
    it "runs the command" do
      connection.expects(:run_command).with("do the thing")
      connection.execute("do the thing")
    end

    it "ignores nil" do
      connection.expects(:run_command).never
      connection.execute(nil)
    end
    describe "for windows-based workstations" do
      before do
        RbConfig::CONFIG.stubs(:[]).with("host_os").returns("mingw32")
        options[:kitchen_root] = "/tmp"
        options[:instance_name] = "instance"
      end

      it "runs the command" do
        stub_file(exec_script, "")
        connection.expects(:run_command).with("powershell -file \"#{exec_script}\"")
        connection.execute("do the thing")
      end

      it "ignores nil" do
        connection.expects(:run_command).never
        connection.execute(nil)
      end
    end
  end

  describe "#close" do
    it "Does not remove exec script file" do
      FileUtils.expects(:remove).with(exec_script).never
      connection.close
    end

    describe "for windows-based workstations" do
      before do
        RbConfig::CONFIG.stubs(:[]).with("host_os").returns("mingw32")
        options[:kitchen_root] = "/tmp"
        options[:instance_name] = "instance"
      end
      it "Removes exec script file" do
        FileUtils.expects(:remove).with(exec_script)
        connection.close
      end
    end
  end

  describe "#upload" do
    it "copies files" do
      FileUtils.expects(:mkdir_p).with("/tmp/kitchen")
      FileUtils.expects(:cp_r).with("/tmp/sandbox/cookbooks", "/tmp/kitchen")
      connection.upload(%w{/tmp/sandbox/cookbooks}, "/tmp/kitchen")
    end
    it "copies files when $env:temp is set" do
      ENV["temp"] = "/tmp"
      FileUtils.expects(:mkdir_p).with("/tmp/kitchen")
      FileUtils.expects(:cp_r).with("/tmp/sandbox/cookbooks", "/tmp/kitchen")
      connection.upload(%w{/tmp/sandbox/cookbooks}, "$env:TEMP\\kitchen")
    end
  end

  private

  def stub_file(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, "wb") { |f| f.write(content) }
  end
end

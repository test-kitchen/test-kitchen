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

describe Kitchen::Transport::Ssh do
  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:config)        { Hash.new }
  let(:state)         { Hash.new }

  let(:instance) do
    stub(name: "coolbeans", logger: logger, to_str: "instance")
  end

  let(:transport) do
    Kitchen::Transport::Exec.new(config).finalize_config!(instance)
  end

  it "provisioner api_version is 1" do
    transport.diagnose_plugin[:api_version].must_equal 1
  end

  it "plugin_version is set to Kitchen::VERSION" do
    transport.diagnose_plugin[:version].must_equal Kitchen::VERSION
  end

  describe "#connection" do
    it "returns a Kitchen::Transport::Exec::Connection object" do
      transport.connection(state).must_be_kind_of Kitchen::Transport::Exec::Connection
    end
  end
end

describe Kitchen::Transport::Exec::Connection do
  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }

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
  end

  describe "#upload" do
    it "copies files" do
      FileUtils.expects(:mkdir_p).with("/tmp/kitchen")
      FileUtils.expects(:cp_r).with("/tmp/sandbox/cookbooks", "/tmp/kitchen")
      connection.upload(%w{/tmp/sandbox/cookbooks}, "/tmp/kitchen")
    end
  end
end

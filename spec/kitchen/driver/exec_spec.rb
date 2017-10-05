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

require "kitchen/driver/exec"

describe Kitchen::Driver::Exec do
  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:state)         { Hash.new }

  let(:config) do
    { reset_command: "mulligan" }
  end

  let(:instance) do
    stub(name: "coolbeans", logger: logger, to_str: "instance", :"transport=" => nil)
  end

  let(:driver) do
    Kitchen::Driver::Exec.new(config).finalize_config!(instance)
  end

  it "plugin_version is set to Kitchen::VERSION" do
    driver.diagnose_plugin[:version].must_equal Kitchen::VERSION
  end

  it "sets the transport to exec" do
    instance.expects(:"transport=").with { |v| v.is_a?(Kitchen::Transport::Exec) }
    driver
  end

  describe "#create" do
    it "runs the reset command" do
      driver.expects(:run_command).with("mulligan")

      driver.create(state)
    end

    it "skips the reset command if :reset_command is falsey" do
      config[:reset_command] = false
      driver.expects(:run_command).never

      driver.create(state)
    end
  end

  describe "#destroy" do
    it "calls the reset command" do
      driver.expects(:run_command).with("mulligan")

      driver.destroy(state)
    end

    it "skips reset command if :reset_command is falsey" do
      config[:reset_command] = false
      driver.expects(:run_command).never

      driver.destroy(state)
    end
  end

end

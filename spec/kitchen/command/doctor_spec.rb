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

require_relative "../../spec_helper"

require "kitchen"
require "kitchen/collection"
require "kitchen/command/doctor"

describe Kitchen::Command::Doctor do
  let(:healthy) { stub(name: "healthy", doctor_action: false) }
  let(:shell)   { stub }

  def doctor(instances, options = {})
    command = Kitchen::Command::Doctor.new(
      ["all"],
      { all: true }.merge(options),
      action: "doctor",
      help: -> {},
      config: stub(instances: Kitchen::Collection.new(instances)),
      shell:
    )
    capture_io { command.call }
  end

  it "doctors the remaining instances after one reports a problem" do
    sick = stub(name: "sick", doctor_action: true)
    later = mock("later")
    later.stubs(:name).returns("later")
    later.expects(:doctor_action).returns(false)

    _ { doctor([sick, later]) }.must_raise SystemExit
  end

  it "exits non-zero when an instance reports a problem" do
    sick = stub(name: "sick", doctor_action: true)

    error = _ { doctor([healthy, sick]) }.must_raise SystemExit

    _(error.status).must_equal 1
  end

  it "does not exit when no instance reports a problem" do
    doctor([healthy])
  end
end

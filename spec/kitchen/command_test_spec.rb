#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

require_relative "../spec_helper"

require "kitchen/command/test"

describe Kitchen::Command::Test do
  let(:command) do
    Kitchen::Command::Test.new([], { destroy: "sometimes" }, shell: mock("shell"))
  end

  it "raises UserError for an invalid destroy mode" do
    error = _ { command.call }.must_raise Kitchen::UserError

    _(error.message).must_equal "Destroy mode must be passing, always, or never."
  end
end

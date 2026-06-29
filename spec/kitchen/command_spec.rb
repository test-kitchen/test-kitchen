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

require "kitchen"
require "kitchen/command"

class RunActionDummy
  include Kitchen::Command::RunAction

  attr_reader :options

  def initialize(options = {})
    @options = options
  end
end

class RunActionInstance
  attr_reader :name

  def initialize(name, failure = nil)
    @name = name
    @failure = failure
    @cleaned = false
  end

  def create(*)
    raise @failure if @failure
  end

  def cleaned?
    @cleaned
  end

  def cleanup!
    @cleaned = true
  end
end

describe Kitchen::Command::RunAction do
  let(:runner) { RunActionDummy.new(concurrency: 2) }

  it "records failures from concurrent actions" do
    instances = [
      RunActionInstance.new("one", Kitchen::ActionFailed.new("first")),
      RunActionInstance.new("two", Kitchen::ActionFailed.new("second")),
    ]

    error = _ { runner.run_action(:create, instances) }
      .must_raise Kitchen::ActionFailed

    _(error.message).must_include "2 actions failed."
    _(error.message).must_include "first on one"
    _(error.message).must_include "second on two"
  end

  it "cleans up instances after action failures" do
    instance = RunActionInstance.new("one", Kitchen::ActionFailed.new("first"))

    _ { runner.run_action(:create, [instance]) }
      .must_raise Kitchen::ActionFailed

    _(instance.cleaned?).must_equal true
  end

  it "restores Thread.abort_on_exception after fail fast runs" do
    original = Thread.abort_on_exception
    Thread.abort_on_exception = false
    instance = RunActionInstance.new("one")

    RunActionDummy.new(concurrency: 1, fail_fast: true)
      .run_action(:create, [instance])

    _(Thread.abort_on_exception).must_equal false
  ensure
    Thread.abort_on_exception = original
  end
end

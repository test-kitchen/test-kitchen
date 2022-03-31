#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2014, Fletcher Nichol
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

require_relative "spec_helper"

require "kitchen"

describe "Kitchen" do
  let(:stdout) { StringIO.new }

  before do
    FakeFS.activate!
    FileUtils.mkdir_p(Dir.pwd)
    stdout.stubs(:tty?).returns(true)
    @orig_stdout = $stdout
    $stdout = stdout
  end

  after do
    $stdout = @orig_stdout
    FakeFS.deactivate!
    FakeFS::FileSystem.clear
  end

  describe "defaults" do
    it "sets DEFAULT_LOG_LEVEL to :info" do
      _(Kitchen::DEFAULT_LOG_LEVEL)
        .must_equal :info
    end

    it "sets DEFAULT_TEST_DIR to test/integration, which is frozen" do
      _(Kitchen::DEFAULT_TEST_DIR)
        .must_equal "test/integration"
      _(Kitchen::DEFAULT_TEST_DIR.frozen?)
        .must_equal true
    end

    it "sets DEFAULT_LOG_DIR to .kitchen/logs, which is frozen" do
      _(Kitchen::DEFAULT_LOG_DIR)
        .must_equal ".kitchen/logs"
      _(Kitchen::DEFAULT_LOG_DIR.frozen?)
        .must_equal true
    end
  end

  it ".tty? returns true if $stdout.tty? is true" do
    _(Kitchen.tty?)
      .must_equal true
  end

  it ".tty? returns flse is $stdout.tty? is false" do
    stdout.stubs(:tty?).returns(false)

    _(Kitchen.tty?)
      .must_equal false
  end

  it ".source_root returns the root path of the gem" do
    _(Kitchen.source_root)
      .must_equal Pathname.new(File.expand_path("..", __dir__))
  end

  it ".default_logger is a Kitchen::Logger" do
    _(Kitchen.default_logger).must_be_instance_of Kitchen::Logger
  end

  it ".default_logger returns a $stdout logger" do
    Kitchen.default_logger.warn("uhoh")

    _(stdout.string).must_match(/ uhoh$/)
  end

  it ".default_file_logger is a Kitchen::Logger" do
    _(Kitchen.default_file_logger).must_be_instance_of Kitchen::Logger
  end

  it ".default_file_logger returns a logger that uses $stdout" do
    Kitchen.default_logger.warn("uhoh")

    _(stdout.string)
      .must_match(/ uhoh$/)
  end

  it ".default_file_logger returns a logger that uses a file" do
    Kitchen.default_file_logger.warn("uhoh")

    _(IO.read(File.join(%w{.kitchen logs kitchen.log})))
      .must_match(/ -- Kitchen: uhoh$/)
  end

  it ".default_file_logger accepts a level and log_overwrite" do
    l = Kitchen.default_file_logger(:error, false)

    _(l.level)
      .must_equal 3
    _(l.log_overwrite)
      .must_equal false
  end

  it "sets Kitchen.logger to a Kitchen::Logger" do
    _(Kitchen.default_logger)
      .must_be_instance_of Kitchen::Logger
  end

  it "sets Kitchen.mutex to a Mutex" do
    _(Kitchen.mutex)
      .must_be_instance_of Mutex
  end
end

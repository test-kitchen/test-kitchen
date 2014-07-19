# -*- encoding: utf-8 -*-
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
      Kitchen::DEFAULT_LOG_LEVEL.must_equal :info
    end

    it "sets DEFAULT_TEST_DIR to test/integration, which is frozen" do
      Kitchen::DEFAULT_TEST_DIR.must_equal "test/integration"
      Kitchen::DEFAULT_TEST_DIR.frozen?.must_equal true
    end

    it "sets DEFAULT_LOG_DIR to .kitchen/logs, which is frozen" do
      Kitchen::DEFAULT_LOG_DIR.must_equal ".kitchen/logs"
      Kitchen::DEFAULT_LOG_DIR.frozen?.must_equal true
    end
  end

  it ".source_root returns the root path of the gem" do
    Kitchen.source_root.
      must_equal Pathname.new(File.expand_path("../..", __FILE__))
  end

  it ".default_logger is a Kitchen::Logger" do
    Kitchen.default_logger.must_be_instance_of Kitchen::Logger
  end

  it ".default_logger returns a $stdout logger" do
    Kitchen.default_logger.warn("uhoh")

    stdout.string.must_match %r{ uhoh$}
  end

  it ".default_file_logger is a Kitchen::Logger" do
    Kitchen.default_file_logger.must_be_instance_of Kitchen::Logger
  end

  it ".default_file_logger returns a logger that uses $stdout" do
    Kitchen.default_logger.warn("uhoh")

    stdout.string.must_match %r{ uhoh$}
  end

  it ".default_file_logger returns a logger that uses a file" do
    Kitchen.default_file_logger.warn("uhoh")

    IO.read(File.join(%w[.kitchen logs kitchen.log])).
      must_match %r{ -- Kitchen: uhoh$}
  end

  it "sets Kitchen.logger to a Kitchen::Logger" do
    Kitchen.default_logger.must_be_instance_of Kitchen::Logger
  end

  it "sets Kitchen.mutex to a Mutex" do
    Kitchen.mutex.must_be_instance_of Mutex
  end
end

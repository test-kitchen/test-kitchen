# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

require_relative '../../spec_helper'
require 'logger'
require 'stringio'

require 'kitchen'

describe Kitchen::Provisioner::Base do

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }
  let(:config)          { Hash.new }

  let(:instance) do
    stub(:name => "coolbeans", :logger => logger)
  end

  let(:provisioner) do
    Kitchen::Provisioner::Base.new(config).finalize_config!(instance)
  end

  it "#name returns the name of the provisioner" do
    provisioner.name.must_equal "Base"
  end

  describe "configuration" do

    it ":root_path defaults to /tmp/kitchen" do
      provisioner[:root_path].must_equal "/tmp/kitchen"
    end

    it ":sudo defaults to true" do
      provisioner[:sudo].must_equal true
    end
  end

  describe "#logger" do

    before  { @klog = Kitchen.logger }
    after   { Kitchen.logger = @klog }

    it "returns the instance's logger" do
      provisioner.send(:logger).must_equal logger
    end

    it "returns the default logger if instance's logger is not set" do
      provisioner = Kitchen::Provisioner::Base.new(config)
      Kitchen.logger = "yep"

      provisioner.send(:logger).must_equal Kitchen.logger
    end
  end

  [:init_command, :install_command, :prepare_command, :run_command].each do |cmd|

    it "has a #{cmd} method" do
      provisioner.public_send(cmd).must_be_nil
    end
  end

  describe "#sudo" do

    it "if :sudo is set, prepend sudo command" do
      config[:sudo] = true

      provisioner.send(:sudo, "wakka").must_equal("sudo -E wakka")
    end

    it "if :sudo is falsy, do not include sudo command" do
      config[:sudo] = false

      provisioner.send(:sudo, "wakka").must_equal("wakka")
    end
  end
end

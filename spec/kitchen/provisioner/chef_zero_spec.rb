# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, Fletcher Nichol
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

require 'kitchen/provisioner/chef_zero'

describe Kitchen::Provisioner::ChefZero do

  let(:logged_output) { StringIO.new }
  let(:config)        { Hash.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:config)        { Hash.new }

  let(:instance) do
    stub(:name => "coolbeans", :logger => logger, :to_str => "instance")
  end

  let(:provisioner) do
    Kitchen::Provisioner::ChefZero.new(instance, config)
  end



  describe "#prepare_command" do
    it "use default ruby path" do
      provisioner.prepare_command.must_include("/opt/chef/embedded/bin")
    end

    it "use ruby_bin path from config" do
      config[:ruby_bin] = "/usr/foo"
      provisioner.prepare_command.must_include("/usr/foo")
    end
  end

  describe "#run_command" do
    it "use default ruby path" do
      provisioner.run_command.must_include("/opt/chef/embedded/bin")
    end

    it "use ruby_bin path from config" do
      config[:ruby_bin] = "/usr/foo"
      provisioner.run_command.must_include("/usr/foo")
    end
  end

end

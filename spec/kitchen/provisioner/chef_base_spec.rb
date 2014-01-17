# -*- encoding: utf-8 -*-
#
# Author:: Chris Lundquist (<chris.lundquist@github.com>)
#
# Copyright (C) 2014, Chris Lundquist
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

require 'kitchen'
require 'kitchen/provisioner/chef_base'

describe Kitchen::Provisioner::ChefBase do
  let(:config)          { { :test_base_path => "tmp" } }
  let(:logger_io)       { StringIO.new }
  let(:instance_logger) { Kitchen::Logger.new(:logdev => logger_io) }

  let(:instance) do
    stub(:name   => "chefinator",
         :logger => instance_logger,
         :suite  => Kitchen::Suite.new(:name => "awesome")
        )
  end

  let(:provisioner) do
    chef_base = Kitchen::Provisioner::ChefBase.new(config)
    chef_base.instance = instance
    chef_base
  end

  describe ".install_command" do
    it "should do things to install chef" do
      command = provisioner.install_command
      command.must_match /Installing Chef/i
      command.must_match /#{Regexp.escape("https://www.getchef.com/chef/install.sh")}/
      command.must_match /do_perl/ # Make sure we have our helpers
    end
  end

end

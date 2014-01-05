# -*- encoding: utf-8 -*-
#
# Author:: Noah Kantrowitz <noah@coderanger.net>
#
# Copyright (C) 2014, Noah Kantrowitz
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
require 'kitchen/provisioner/chef_base'

describe Kitchen::Provisioner::ChefBase do

  let(:config)          { {:test_base_path => '/'} }
  let(:logger_io)       { StringIO.new }
  let(:instance_logger) { Kitchen::Logger.new(:logdev => logger_io) }

  let(:instance) do
    stub(:name => "coolbeans", :logger => instance_logger, :suite => stub(:name => "teststuff"))
  end

  let(:provisioner) do
    p = Kitchen::Provisioner::ChefBase.new(config)
    p.instance = instance
    p
  end

  describe "#install_command" do

    it 'installs Chef by default' do
      provisioner.install_command.must_include 'do_download https://www.getchef.com/chef/install.sh'
    end

    it 'does not install Chef when require_chef_omnibus is false' do
      config[:require_chef_omnibus] = false
      provisioner.install_command.must_equal ''
    end

    it 'installs the requested version of Chef when require_chef_omnibus is set' do
      config[:require_chef_omnibus] = '3.1.4'
      provisioner.install_command.must_include 'do_download https://www.getchef.com/chef/install.sh'
      provisioner.install_command.must_include 'install.sh -v 3.1.4'
    end

    it 'runs the configured pre_install_command and installs Chef' do
      config[:pre_install_command] = 'sudo crazygonuts'
      provisioner.install_command.must_include 'sudo crazygonuts'
      provisioner.install_command.must_include 'do_download https://www.getchef.com/chef/install.sh'
    end

    it 'runs the configured pre_install_command and installs Chef' do
      config[:pre_install_command] = 'sudo crazygonuts'
      provisioner.install_command.must_include 'sudo crazygonuts'
      provisioner.install_command.must_include 'do_download https://www.getchef.com/chef/install.sh'
    end

    it 'runs the configured pre_install_command but does not install Chef when require_chef_omnibus is false' do
      config[:pre_install_command] = 'sudo crazygonuts'
      config[:require_chef_omnibus] = false
      provisioner.install_command.must_include 'sudo crazygonuts'
      provisioner.install_command.wont_include 'do_download https://www.getchef.com/chef/install.sh'
    end

  end

end

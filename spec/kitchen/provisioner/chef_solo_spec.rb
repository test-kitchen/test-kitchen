# -*- encoding: utf-8 -*-
#
# Author:: Tobias Panknin (<tobiaspanknin@gmail.com>)
#
# Copyright (C) 2013, Tobias Panknin
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
require 'stringio'

#require 'kitchen'
require 'kitchen/provisioner/chef_solo'

describe Kitchen::Provisioner::ChefSolo do

  let(:config)          { Hash.new }
  let(:provisioner) do
    Kitchen::Provisioner::ChefSolo.new(config)
  end

  it "#name returns its class name as a string" do
    provisioner.name.must_equal "ChefSolo"
  end

  it "config must contain key 'chef_path'" do
    provisioner.config_keys.must_include(:chef_path)
  end

  it "config key 'chef_path' must be nil by default" do
    provisioner[:chef_path].must_be_nil
  end

  it 'run_command() must not prefix chef-solo with anything' do
    provisioner.run_command.must_match(/^(sudo -E )?chef-solo/)
  end

  describe "config hash is passed to instance" do
    let(:config) do
      config = Hash.new
      config[:chef_path] = '/test'
      config
    end

    let(:provisioner) do
      Kitchen::Provisioner::ChefSolo.new(config)
    end

    it "config must contain key 'chef_path'" do
      provisioner.config_keys.must_include(:chef_path)
    end

    it "config key 'chef_path' must have the same value as in config hash passed to instance" do
      provisioner[:chef_path].must_be_same_as config[:chef_path]
    end

    it 'run_command() must prefix chef-solo with value of chef_path' do
      provisioner.run_command.must_match(/^(sudo -E )?#{provisioner[:chef_path]}\/chef-solo/)
    end
  end

  describe "config key 'chef_path' has trailing slash" do
    let(:config) do
      config = Hash.new
      config[:chef_path] = '/test/'
      config
    end

    let(:provisioner) do
      Kitchen::Provisioner::ChefSolo.new(config)
    end

    it "run_command() must prefix chef-solo with value of config key 'chef_path' minus the trialing slash"  do
      chef_path = provisioner[:chef_path].gsub(/\/$/,'')
      provisioner.run_command.must_match(/^(sudo -E )?#{chef_path}\/chef-solo/)
    end
  end

end

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

require_relative '../spec_helper'

require 'kitchen/errors'
require 'kitchen/suite'

describe Kitchen::Suite do

  let(:opts) do ; { :name => 'suitezy', :run_list => ['doowah'] } ; end
  let(:suite) { Kitchen::Suite.new(opts) }

  it "raises an ArgumentError if name is missing" do
    opts.delete(:name)
    proc { Kitchen::Suite.new(opts) }.must_raise Kitchen::ClientError
  end

  describe 'Cheflike' do

    let(:suite) { Kitchen::Suite.new(opts).extend(Kitchen::Suite::Cheflike) }

    it "returns an empty Hash given no attributes" do
      suite.attributes.must_equal Hash.new
    end

    it "returns an empty Array given no excludes" do
      suite.excludes.must_equal Array.new
    end

    it "returns an empty Array given no includes" do
      suite.includes.must_equal Array.new
    end

    it "returns nil given no data_bags_path" do
      suite.data_bags_path.must_be_nil
    end

    it "returns nil given no roles_path" do
      suite.roles_path.must_be_nil
    end

    it "returns nil given no nodes_path" do
      suite.nodes_path.must_be_nil
    end

    it "returns nil given no encrypted_data_bag_secret_key_path" do
      suite.encrypted_data_bag_secret_key_path.must_be_nil
    end

    it "returns attributes from constructor" do
      opts.merge!({ :attributes => { :a => 'b' }, :data_bags_path => 'crazy',
        :roles_path => 'town', :nodes_path => 'woowoo',
        :encrypted_data_bag_secret_key_path => 'secret' })
      suite.name.must_equal 'suitezy'
      suite.run_list.must_equal ['doowah']
      suite.attributes.must_equal({ :a => 'b' })
      suite.data_bags_path.must_equal 'crazy'
      suite.roles_path.must_equal 'town'
      suite.nodes_path.must_equal 'woowoo'
      suite.encrypted_data_bag_secret_key_path.must_equal 'secret'
    end
  end
end

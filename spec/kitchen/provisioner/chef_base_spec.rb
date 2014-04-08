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

require_relative '../../spec_helper'

require 'kitchen'
require 'kitchen/provisioner/chef_base'

describe Kitchen::Provisioner::ChefBase do

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }

  let(:config) do
    { :test_base_path => "/basist", :kitchen_root => "/rooty" }
  end

  let(:suite) do
    stub(:name => "fries")
  end

  let(:instance) do
    stub(:name => "coolbeans", :logger => logger, :suite => suite)
  end

  let(:provisioner) do
    Class.new(Kitchen::Provisioner::ChefBase) {
      def calculate_path(path, opts = {})
        "<calculated>/#{path}"
      end
    }.new(config).finalize_config!(instance)
  end

  describe "configuration" do

    it ":require_chef_omnibus defaults to true" do
      provisioner[:require_chef_omnibus].must_equal true
    end

    it ":chef_omnibus_url has a default" do
      provisioner[:chef_omnibus_url].
        must_equal "https://www.getchef.com/chef/install.sh"
    end

    it ":run_list defaults to an empty array" do
      provisioner[:run_list].must_equal []
    end

    it ":attributes defaults to an empty hash" do
      provisioner[:attributes].must_equal Hash.new
    end

    it ":cookbook_files_glob includes recipes" do
      provisioner[:cookbook_files_glob].must_match %r{,recipes/}
    end

    it ":data_path uses calculate_path and is expanded" do
      provisioner[:data_path].must_equal "/rooty/<calculated>/data"
    end

    it ":data_bags_path uses calculate_path and is expanded" do
      provisioner[:data_bags_path].must_equal "/rooty/<calculated>/data_bags"
    end

    it ":environments_path uses calculate_path and is expanded" do
      provisioner[:environments_path].
        must_equal "/rooty/<calculated>/environments"
    end

    it ":nodes_path uses calculate_path and is expanded" do
      provisioner[:nodes_path].must_equal "/rooty/<calculated>/nodes"
    end

    it ":roles_path uses calculate_path and is expanded" do
      provisioner[:roles_path].must_equal "/rooty/<calculated>/roles"
    end

    it ":clients_path uses calculate_path and is expanded" do
      provisioner[:clients_path].must_equal "/rooty/<calculated>/clients"
    end

    it ":encrypted_data_bag_secret_key_path uses calculate_path and is expanded" do
      provisioner[:encrypted_data_bag_secret_key_path].
        must_equal "/rooty/<calculated>/encrypted_data_bag_secret_key"
    end
  end
end

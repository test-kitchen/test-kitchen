#
# Author:: Steven Danna (<steve@opscode.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative '../../../spec_helper'

require 'test-kitchen'
require 'test-kitchen/runner/openstack/dsl'
require 'test-kitchen/runner/openstack/environment'

module TestKitchen::DSL

  module Helper
    def dsl_instance(dsl_module)
      Class.new do
        include dsl_module
        def env
          TestKitchen::Environment.new(:ignore_kitchenfile => true)
        end
      end.new
    end
  end

  describe BasicDSL do
    include Helper
    let(:dsl) { dsl_instance(BasicDSL) }

    it "allows the openstack username to be set" do
      dsl.openstack do
        username "bob"
      end
      TestKitchen::Environment::Openstack.config.username.must_equal "bob"
    end

    it "allows the openstack password to be set" do
      dsl.openstack do
        password "password"
      end
      TestKitchen::Environment::Openstack.config.password.must_equal "password"
    end

    it "allows the openstack auth_url to be set" do
      dsl.openstack do
        auth_url "http://example.com"
      end
      TestKitchen::Environment::Openstack.config.auth_url.must_equal "http://example.com"
    end

    it "allows the openstack tenant to be set" do
      dsl.openstack do
        tenant "openstack"
      end
      TestKitchen::Environment::Openstack.config.tenant.must_equal "openstack"
    end
  end
end

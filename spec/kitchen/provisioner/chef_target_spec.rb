#
# Author:: Thomas Heinen (<thomas.heinen@gmail.com>)
#
# Copyright (C) 2024, Thomas Heinen
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

require_relative "../../spec_helper"

require "kitchen"
require "kitchen/provisioner/chef_target"

module Train
  module Plugins
    module Transport
      class Dummy; end
    end
  end
end

describe Kitchen::Provisioner::ChefTarget do
  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }
  let(:platform)        { stub(os_type: nil) }
  let(:suite)           { stub(name: "fries") }
  let(:transport)       { Train::Plugins::Transport::Dummy.new }
  let(:connection)      { transport.stubs(:connection).returns(nil) }

  let(:config) do
    { test_base_path: "/b", kitchen_root: "/r" }
  end

  let(:instance) do
    stub(
      name: "coolbeans",
      logger: logger,
      suite: suite,
      platform: platform
    )
  end

  let(:provisioner) do
    Kitchen::Provisioner::ChefTarget.new(config).finalize_config!(instance)
  end

  describe "overrides" do
    it "fix install_strategy to none" do
      _(provisioner[:install_strategy]).must_equal "none"
    end

    it "force sudo" do
      _(provisioner[:sudo]).must_equal true
    end

    it "remove install_command" do
      _(provisioner.install_command).must_be_empty
    end

    it "remove init_command" do
      _(provisioner.init_command).must_be_empty
    end

    it "remove prepare_command" do
      _(provisioner.prepare_command).must_be_empty
    end
  end

  describe "check_transport" do
    describe "with train transport" do
      let(:connection) { stub(respond_to?: true) }

      it "accepts the transport" do
        _(provisioner.check_transport(connection)).must_equal true
      end
    end

    describe "with non-train transport" do
      let(:connection) { stub(respond_to?: false) }

      it "rejects the transport" do
        _ { provisioner.check_transport(connection) }.must_raise Kitchen::Provisioner::ChefTarget::RequireTrainTransport
      end
    end
  end

  describe "check_local_chef_client" do
    it "must accept >= 19.0.0" do
      provisioner.stubs(:`).returns("Chef Infra Client: 19.0.1\n")
      _(provisioner.check_local_chef_client).must_equal true
    end

    it "must reject < 19.0.0" do
      provisioner.stubs(:`).returns("Chef Infra Client: 18.2.5\n")
      _ { provisioner.check_local_chef_client }.must_raise Kitchen::Provisioner::ChefTarget::ChefVersionTooLow
    end
  end
end

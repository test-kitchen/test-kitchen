# -*- encoding: utf-8 -*-
#
# Author:: Tyler Ball (<tball@chef.io>)
#
# Copyright (C) 2015, Fletcher Nichol
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

require "kitchen/driver/aws/client"
require "climate_control"

describe Kitchen::Driver::Aws::Client do
  describe "::get_credentials" do
    let(:shared) { instance_double(Aws::SharedCredentials) }
    let(:iam) { instance_double(Aws::InstanceProfileCredentials) }

    before do
      expect(Aws::SharedCredentials).to \
        receive(:new).with(:profile_name => "profile").and_return(shared)
    end

    # nothing else is set, so we default to this
    it "loads IAM credentials last" do
      expect(shared).to receive(:loadable?).and_return(false)
      expect(Aws::InstanceProfileCredentials).to receive(:new).and_return(iam)
      expect(Kitchen::Driver::Aws::Client.get_credentials("profile", nil, nil, nil)).to eq(iam)
    end

    it "loads shared credentials second to last" do
      expect(shared).to receive(:loadable?).and_return(true)
      expect(Kitchen::Driver::Aws::Client.get_credentials("profile", nil, nil, nil)).to eq(shared)
    end

    it "loads shared credentials third to last" do
      expect(shared).to_not receive(:loadable?)
      ClimateControl.modify(
        "AWS_ACCESS_KEY_ID" => "key1",
        "AWS_SECRET_ACCESS_KEY" => "value1",
        "AWS_SESSION_TOKEN" => "token1"
      ) do
        expect(Kitchen::Driver::Aws::Client.get_credentials("profile", nil, nil, nil)).to \
          be_a(Aws::Credentials).and have_attributes(
            :access_key_id => "key1",
            :secret_access_key => "value1",
            :session_token => "token1"
          )
      end
    end

    it "loads deprecated credentials fourth to last" do
      expect(shared).to_not receive(:loadable?)
      ClimateControl.modify(
        "AWS_ACCESS_KEY" => "key2",
        "AWS_SECRET_KEY" => "value2",
        "AWS_TOKEN" => "token2"
      ) do
        expect(Kitchen::Driver::Aws::Client.get_credentials("profile", nil, nil, nil)).to \
          be_a(Aws::Credentials).and have_attributes(
            :access_key_id => "key2",
            :secret_access_key => "value2",
            :session_token => "token2"
          )
      end
    end

    it "loads provided credentials first" do
      expect(shared).to_not receive(:loadable?)
      expect(Kitchen::Driver::Aws::Client.get_credentials("profile", "key3", "value3", nil)).to \
        be_a(Aws::Credentials).and have_attributes(
         :access_key_id => "key3",
         :secret_access_key => "value3",
         :session_token => nil
       )
    end

    it "uses a session token if provided" do
      expect(shared).to_not receive(:loadable?)
      expect(Kitchen::Driver::Aws::Client.get_credentials("profile", "key3", "value3", "t")).to \
        be_a(Aws::Credentials).and have_attributes(
         :access_key_id => "key3",
         :secret_access_key => "value3",
         :session_token => "t"
       )
    end
  end

  let(:client) { Kitchen::Driver::Aws::Client.new("us-west-1") }

  describe "#initialize" do

    it "successfully creates a client" do
      expect(client).to be_a(Kitchen::Driver::Aws::Client)
    end

    it "Sets the AWS config" do
      client
      expect(Aws.config[:region]).to eq("us-west-1")
    end
  end

  it "returns a client" do
    expect(client.client).to be_a(Aws::EC2::Client)
  end

  it "returns a resource" do
    expect(client.resource).to be_a(Aws::EC2::Resource)
  end

end

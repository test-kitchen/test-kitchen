# -*- encoding: utf-8 -*-
#
# Author:: Matt Wrock (<matt@mattwrock.com>)
#
# Copyright (C) 2014, Matt Wrock
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
require "kitchen/configurable"
require "kitchen/driver/dummy"
require "kitchen/transport/base"
require "kitchen/transport/winrm"

describe Kitchen::Transport::Winrm do

  let(:logged_output)   { StringIO.new }
  let(:logger)          { Logger.new(logged_output) }
  let(:config)          { Hash.new }
  let(:driver)          { Kitchen::Driver::Dummy.new(config) }
  let(:state)           { Hash.new }

  let(:instance) do
    stub(
      :name => "coolbeans",
      :logger => logger,
      :transport => transport,
      :driver => driver
    )
  end

  let(:service) do
    stub(
      :set_timeout => nil
    )
  end

  let(:transport) { Kitchen::Transport::Winrm.new(config) }

  let(:remote_file) do
    stub(
      :upload  => nil,
      :close => nil
    )
  end

  let(:remote_zip_file) do
    stub(
      :upload  => nil,
      :add_file => nil,
      :close => nil
    )
  end

  before {
    Kitchen::Transport::WinRMFileTransfer::RemoteFile.stubs(:new).returns(remote_file)
    Kitchen::Transport::WinRMFileTransfer::RemoteZipFile.stubs(:new).returns(remote_zip_file)
    WinRM::WinRMWebService.stubs(:new).returns(service)
    transport.finalize_config!(instance)
  }

  describe "upload!" do

    describe "single file" do
      it "uploads using a remote_file" do
        remote_file.expects(:upload)

        transport.connection(state) do |conn|
          conn.upload! "/tmp/blah.txt", "/tmp/kitchen/blah.txt"
        end
      end

      it "closes the remote_file" do
        remote_file.expects(:close)

        transport.connection(state) do |conn|
          conn.upload! "/tmp/blah.txt", "/tmp/kitchen/blah.txt"
        end
      end
    end

    describe "multiple files" do
      it "uploads using a remote_zip_file" do
        remote_zip_file.expects(:upload)

        transport.connection(state) do |conn|
          conn.upload! ["/tmp/blah.txt", "/tmp/blah2.txt"], "/tmp/kitchen"
        end
      end

      it "closes the remote_zip_file" do
        remote_zip_file.expects(:close)

        transport.connection(state) do |conn|
          conn.upload! ["/tmp/blah.txt", "/tmp/blah2.txt"], "/tmp/kitchen"
        end
      end
    end

    describe "directory" do
      before do
        @temp = Dir.mktmpdir
      end

      after do
        FileUtils.remove_entry(@temp)
      end

      it "uploads using a remote_zip_file" do
        remote_zip_file.expects(:upload)

        transport.connection(state) do |conn|
          conn.upload! @temp, "/tmp/kitchen"
        end
      end

      it "closes the remote_zip_file" do
        remote_zip_file.expects(:close)

        transport.connection(state) do |conn|
          conn.upload! @temp, "/tmp/kitchen"
        end
      end
    end
  end
end

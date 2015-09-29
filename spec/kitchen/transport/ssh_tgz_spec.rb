# -*- encoding: utf-8 -*-
#
# Author:: Peter Smith (<peter@petersmith.net>)
#
# Copyright (C) 2015, Peter Smith
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

require "kitchen/transport/ssh_tgz"

describe Kitchen::Transport::SshTgz do

  #
  # Create temporary files, of a given size/content. Used as test
  # files for tar-gzipping.
  #
  def make_temp_file(content, size)
    file = Tempfile.new("file")
    file.write(content * size)
    file.close
    file.path
  end

  let(:file_A)          { make_temp_file("A", 100) }
  let(:file_B)          { make_temp_file("B", 200) }
  let(:file_C)          { make_temp_file("C", 300) }

  #
  # Create a mock SCP session, so we capture the arguments and return values that would be passed to
  # the upload! method.
  #
  let(:mock_session)    { mock("session") }
  let(:mock_scp)        { mock("scp") }

  before do
    Kitchen::Transport::SshTgz::Connection.any_instance.stubs(:session).returns(mock_session)
    mock_session.stubs(:scp).returns(mock_scp)
  end

  it "does not upload anything, if no files are provided" do
    #
    # No uploading or exec'ing should take place.
    #
    mock_scp.expects(:upload!).never
    mock_session.expects(:exec!).never

    #
    # Run the test...
    #
    connection = Kitchen::Transport::SshTgz::Connection.new
    connection.upload([], "/tmp/remote")
  end

  it "compresses multiple files into a single upload" do
    #
    # the tgz file must first be uploaded. Exactly one upload will occur.
    #
    mock_scp.expects(:upload!).once.with do |source_file, dest_file, _|
      # compressed file sizes can vary slightly, since tar files contain date stamps,
      # which compress unpredictably.
      size = Kitchen::Tgz.original_size(source_file)
      dest_file == "/tmp/remote/kitchen.tgz" && size == 4096
    end

    #
    # then, the tgz file must be extracted on the remote host.
    #
    mock_session.expects(:exec!).once.with("tar -C /tmp/remote -xmzf /tmp/remote/kitchen.tgz")

    #
    # Run the test...
    #
    connection = Kitchen::Transport::SshTgz::Connection.new
    connection.upload([file_A, file_B, file_C], "/tmp/remote")
  end
end

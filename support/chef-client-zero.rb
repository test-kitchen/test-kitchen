#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

require 'rubygems'
require 'chef'
require 'chef/application/client'
require 'chef_zero/server'
require 'chef/knife/serve_essentials'
require 'tmpdir'

client = Chef::Application::Client.new
client.reconfigure

data_store = Chef::Knife::Serve::ChefFSDataStore.new(
  proc do
    hash = Hash.new
    %w(client cookbook data_bag node role).each do |object_name|
      paths = Array(Chef::Config["#{object_name}_path"]).flatten
      hash["#{object_name}s"] = paths.map { |path| File.expand_path(path) }
    end
    ChefFS::FileSystem::ChefRepositoryFileSystemRootDir.new(hash)
  end
)

server_opts = {
  :host => "127.0.0.1",
  :port => 8889,
  :generate_real_keys => false,
  :data_store => data_store
}

Chef::Log.info("Starting Chef Zero server in background")
server = ChefZero::Server.new(server_opts)
server.start_background
at_exit do
  Chef::Log.info("Shutting down Chef Zero server")
  server.stop
end

Dir.mktmpdir do |tmpdir|
  File.open(File.join(tmpdir, "validation.pem"), "wb") do |f|
    f.write(server.gen_key_pair.first)
  end
  Chef::Config[:validation_key] = File.join(tmpdir, "validation.pem")
  Chef::Config[:client_key] = File.join(tmpdir, "client.pem")
  Chef::Config[:chef_server_url] = server.url
  client.setup_application
  client.run_application
end

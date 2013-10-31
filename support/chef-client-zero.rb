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

begin
  # chef_fs is now in core chef >= 11.8
  require 'chef/chef_fs/chef_fs_data_store'
  require 'chef/chef_fs/config'
rescue LoadError
  # backwards compatibility with chef-essentials gem
  require 'chef_fs/chef_fs_data_store'
  require 'chef_fs/config'
end
require 'tmpdir'

client = Chef::Application::Client.new
client.reconfigure

if Chef.const_defined?('ChefFS')
  # chef_fs is now in core chef >= 11.8
  data_store = Chef::ChefFS::ChefFSDataStore.new(
    Chef::ChefFS::Config.new(Chef::Config).local_fs
  )
else
  # backwards compatibility with chef-essentials gem
  data_store = ChefFS::ChefFSDataStore.new(
    ChefFS::Config.new(Chef::Config).local_fs
  )
end

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

#
# Author:: Andrew Crump (<andrew@kotirisoftware.com>)
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

remote_file "/tmp/toft.deb" do
  source "http://dl.dropbox.com/u/43220259/toft-lxc_0.0.6_all.deb"
  mode "0600"
end

package "apparmor" do
  action :remove
end

package "toft-lxc" do
  source "/tmp/toft.deb"
  provider Chef::Provider::Package::Dpkg
  ignore_failure true
  action :install
end

execute "install-dependencies" do
  command "apt-get -y -f install"
  action :run
end

%w{ruby1.8 rubygems1.8}.each do |ruby18_pkg|
  package ruby18_pkg do
    action :install
  end
end

%w{json toft}.each do |toft_gem|
  gem_package toft_gem do
    gem_binary "gem1.8"
    action :install
  end
end

directory "/var/cache/lxc" do
  recursive true
  action :create
end

node['test-kitchen']['lxc-image-urls'].each_pair do |local_name, remote_image|
  # Hack for mapping platform to template names
  local_name = {'centos-6.2' => 'centos-6', 'ubuntu-11.04' => 'natty'}[local_name]
  remote_file "/var/cache/lxc/#{local_name}-i386.tar.gz" do
    source remote_image
    action :create_if_missing
  end
end

execute "lxc-prepare-host" do
  action :run
end

project = node['test-kitchen']['project']
lxc_run_list = ['test-kitchen::default']
lxc_run_list << "test-kitchen::#{project['language'] || 'chef'}"
lxc_run_list << project['run_list_extras'] if project['run_list_extras']

template "/usr/bin/test-kitchen-lxc" do
  variables({
    'project' => node['test-kitchen']['project'],
    'test_user' => node['test-kitchen']['user'],
    'test_group' => node['test-kitchen']['group'],
    'run_list' => lxc_run_list
  })
  mode "00700"
  action :create
end

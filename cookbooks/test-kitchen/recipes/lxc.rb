toft_base_url = "http://dl.dropbox.com/u/43220259"

remote_file "/tmp/toft.deb" do
  source "#{toft_base_url}/toft-lxc_0.0.6_all.deb"
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

['natty', 'centos-6'].each do |container_image| # %w{lucid natty centos-6 lenny}
  image_file = "#{container_image}-amd64.tar.gz"
  remote_file "/var/cache/lxc/#{image_file}" do
    source "#{toft_base_url}/#{image_file}"
    action :create_if_missing
  end
end

execute "lxc-prepare-host" do
  action :run
end

lxc_run_list = ['test-kitchen::default']
lxc_run_list << "test-kitchen::#{node['test-kitchen']['project']['language'] || 'chef'}"

project = node['test-kitchen']['project']
lxc_run_list << "#{project['name']}::default"

if node['test-kitchen']['project']['run_list_extras']
  lxc_run_list << node['test-kitchen']['project']['run_list_extras']
end


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

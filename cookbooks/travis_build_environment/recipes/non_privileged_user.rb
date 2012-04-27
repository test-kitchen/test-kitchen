#
# Cookbook Name:: travis_build_environment
# Recipe:: non_privileged_user
# Copyright 2011, Travis CI development team
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


cookbook_file "/etc/profile.d/travis_environment.sh" do
  owner node.travis_build_environment.user
  group node.travis_build_environment.group
  mode 0755

  source "vagrant/travis_environment.sh"
end


cookbook_file "#{node.travis_build_environment.home}/.gemrc" do
  owner node.travis_build_environment.user
  group node.travis_build_environment.group
  mode 0755

  source "vagrant/dot_gemrc.yml"
end


template "#{node.travis_build_environment.home}/.bashrc" do
  owner node.travis_build_environment.user
  group node.travis_build_environment.group
  mode 0755

  source "vagrant/dot_bashrc.sh"
end


directory "#{node.travis_build_environment.home}/.ssh" do
  owner  node.travis_build_environment.user
  group  node.travis_build_environment.group
  mode   "0755"

  action :create
end


cookbook_file "#{node.travis_build_environment.home}/.ssh/known_hosts" do
  owner node.travis_build_environment.user
  group node.travis_build_environment.group
  mode  0600

  source "vagrant/known_hosts"
end


directory "#{node.travis_build_environment.home}/builds" do
  owner node.travis_build_environment.user
  group node.travis_build_environment.group
  mode "0755"
  action :create
end


mount "#{node.travis_build_environment.home}/builds" do
  fstype   "tmpfs"
  device   "/dev/null" # http://tickets.opscode.com/browse/CHEF-1657, doesn't seem to be included in 0.10.0
  options  "defaults,size=#{node.travis_build_environment.builds_volume_size},noatime"
  action   [:mount, :enable]
  only_if { node.travis_build_environment[:use_tmpfs_for_builds] }
end

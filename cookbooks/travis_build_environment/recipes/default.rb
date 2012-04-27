#
# Cookbook Name:: travis_build_environment
# Recipe:: default
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

include_recipe "timezone"

include_recipe "travis_build_environment::root"
include_recipe "travis_build_environment::non_privileged_user"

cookbook_file "/etc/default/locale" do
  owner "root"
  group "root"
  mode 0644

  source "etc/default/locale.sh"
end

template "/etc/hosts" do
  owner "root"
  group "root"
  mode 0644

  source "etc/hosts.erb"
end

template "/etc/security/limits.conf" do
  owner "root"
  group "root"
  mode 0644

  source "etc/security/limits.conf.erb"
end

template "/etc/apt/apt.conf.d/60assumeyes" do
  owner "root"
  group "root"
  mode 0644

  source "etc/apt/assumeyes.erb"
end

include_recipe "iptables"


# wipe out apparmor on 11.04, it may be a useful thing for typical servers but
# in our case it is a major annoyance and nothing else. MK.
package "apparmor" do
  action :remove
  ignore_failure true
end

package "apparmor-utils" do
  action :remove
  ignore_failure true
end

# improve sshd startup stability. See https://github.com/jedi4ever/veewee/issues/159 for rationale
# and some stats about boot failures. MK.
execute "rm /etc/update-motd.d/*" do
  ignore_failure true
end

# Make sure we don't have obscure issues with SSL certificates.
# See https://bugs.launchpad.net/ubuntu/+source/ca-certificates-java/+bug/873517
# and http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=623671. MK.
execute "/usr/sbin/update-ca-certificates -f" do
  user "root"
end

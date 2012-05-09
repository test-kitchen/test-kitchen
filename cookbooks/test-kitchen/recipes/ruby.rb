#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
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

project = node.run_state[:project]

node['rvm']['user_installs'] = [
  { 'user' => node['test-kitchen']['user'] }
]

gemfile_path = File.join(project['test_root'], 'Gemfile')

# TODO - remove this when test-kitchen is public
ruby_block "remove test-kitchen entry in Gemfile" do
  block do
    require 'chef/util/file_edit'
    fe = Chef::Util::FileEdit.new(gemfile_path)
    fe.search_file_delete_line(/gem ['"]test-kitchen['"]/)
    fe.write_file
  end
end

# ensure we blow away Gemfile.lock
file "#{gemfile_path}.lock" do
  action :delete
end

include_recipe "rvm::user_install"

project['runtimes'].each do |runtime|

  rvm_ruby runtime do
    user node['test-kitchen']['user']
    action :install
  end

  # default gems
  %w{ bundler rake }.each do |gem|
    rvm_gem gem do
      ruby_string runtime
      user node['test-kitchen']['user']
      action :install
    end
  end

  rvm_shell "[#{runtime}] bundle for [#{project['test_root']}]" do
    ruby_string runtime
    user node['test-kitchen']['user']
    group node['test-kitchen']['group']
    cwd project['test_root']
    code project['install']
  end

end

rvm_default_ruby '1.9.2' do
  user node['test-kitchen']['user']
  action :create
end

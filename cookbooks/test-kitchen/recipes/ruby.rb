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
  puts "ROOT => #{project['test_root']}"
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

project = node.run_state[:project]

gemfile_path = File.join(project['test_root'], 'test', 'Gemfile')

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

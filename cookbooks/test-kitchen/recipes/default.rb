# Make sure that the package list is up to date
case node[:platform]
when 'debian', 'ubuntu'
  include_recipe "apt"
when 'centos','redhat'
  include_recipe "yum::epel"
end

# include_recipe 'git'

project = node['test-kitchen']['project']
project_root = node['test-kitchen']['project_root']
source_root = node['test-kitchen']['source_root']
test_root = node['test-kitchen']['test_root']

execute "stage source in test root" do
  command "rsync -aHv --update --progress --checksum #{source_root}/ #{test_root} "
end

# # make the project_root available to other recipes
# node.run_state[:project] = project

# language = project['language']

# # if a project specific recipe exists use it for additional setup
# if recipe_for_project?(project['name'])

#   include_recipe "kitchen::#{name}"

# end

# # # ensure projects declared langauge toolchain is present
# include_recipe "test-kitchen::#{language}"

# Make sure that the package list is up to date
case node[:platform]
when 'debian', 'ubuntu'
  include_recipe "apt"
when 'centos','redhat'
  include_recipe "yum::epel"
end

# include_recipe 'travis_build_environment::root'
# include_recipe 'travis_build_environment::non_privileged_user'
# include_recipe 'git'
# include_recipe 'test-kitchen::github'

# projects = node['test-kitchen']['projects']
# test_root = node['test-kitchen']['test_root']

# directory test_root do
#   action :create
# end

# opts['project_root'] = "#{test_root}/#{name}"

# # make the project_root available to other recipes
# node.run_state[:project_config] = opts

# language = opts['language']

# # check the code out
# git name do
#   destination opts['project_root']
#   repository opts['repository']
#   revision opts['revision'] || "master"
#   user node.travis_build_environment.user
#   group node.travis_build_environment.group
#   action :sync
# end

# # if a project specific recipe exists use it for additional setup
# if recipe_for_project?(name)

#   include_recipe "test-kitchen::#{name}"

# end

# # ensure projects declared langauge toolchain is present
# include_recipe "test-kitchen::#{language}"

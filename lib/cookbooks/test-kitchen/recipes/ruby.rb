project_config = node.run_state[:project_config]

node[:rvm][:rubies]       = [{ :name => "1.8.7" },
                             { :name => "1.9.2" }]
node[:rvm][:default]      = "1.9.2"
node[:rvm][:default_gems] = %w(bundler rake)

include_recipe "rvm::multi"

rvm_versions = project_config['rvm'] || [ node[:rvm][:default] ]

rvm_versions.each do |rvm_version|

  # TODO - make a 'test-kitchen_rvm_shell' LWRP for this
  bash "[#{rvm_version}] bundle for [#{project_config['project_root']}]" do
    code <<-CODE
      if [ -s "${HOME}/.rvm/scripts/rvm" ]; then
        source "${HOME}/.rvm/scripts/rvm"
      elif [ -s "/home/vagrant/.profile" ]; then
        source "/home/vagrant/.profile"
      fi

      rvm use #{rvm_version}
      #{project_config.key?('install') ?
        project_config['install'] : "bundle install"}
    CODE
    cwd project_config['project_root']
    user node.travis_build_environment.user
    group node.travis_build_environment.group
    environment ({
      'USER' => node.travis_build_environment.user,
      'HOME' => node.travis_build_environment.home
    })
  end

end

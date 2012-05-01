
# stop strict host key checking on github.com
execute 'no-github-key-checking' do
  command "echo '\nHost github.com\n\tStrictHostKeyChecking no' >> /etc/ssh/ssh_config"
  action :run
  not_if "cat /etc/ssh/ssh_config | grep github.com"
end

# ensure sudo inherits the SSH_AUTH_SOCK
execute 'sudo-ssh-auth-sock' do
  command "echo '\nDefaults env_keep+=SSH_AUTH_SOCK' >> /etc/sudoers"
  action :run
  not_if "cat /etc/sudoers | grep SSH_AUTH_SOCK"
end

# ensure the current chef-solo process honors SSH_AUTH_SOCK
# http://stackoverflow.com/questions/7211287/use-ssh-keys-with-passphrase-on-a-vagrantchef-setup
ruby_block "Give root access to the forwarded ssh agent" do
  block do
    # find a parent process' ssh agent socket
    agents = {}
    ppid = Process.ppid
    Dir.glob('/tmp/ssh*/agent*').each do |fn|
      agents[fn.match(/agent\.(\d+)$/)[1]] = fn
    end
    while ppid != '1'
      if (agent = agents[ppid])
        ENV['SSH_AUTH_SOCK'] = agent
        break
      end
      File.open("/proc/#{ppid}/status", "r") do |file|
        ppid = file.read().match(/PPid:\s+(\d+)/)[1]
      end
    end
    # Uncomment to require that an ssh-agent be available
    # fail "Could not find running ssh agent - Is config.ssh.forward_agent enabled in Vagrantfile?" unless ENV['SSH_AUTH_SOCK']
  end
  action :create
end

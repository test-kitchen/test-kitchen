# -*- encoding: utf-8 -*-

require 'jamie'

module Jamie

  module Driver

    # Vagrant driver for Jamie. It communicates to Vagrant via the CLI.
    class Vagrant < Jamie::Driver::SSHBase

      default_config 'memory', '256'

      def perform_create(instance, state)
        state['name'] = instance.name
        run_command "vagrant up #{state['name']} --no-provision"
      end

      def perform_converge(instance, state)
        run_command "vagrant provision #{state['name']}"
      end

      def perform_destroy(instance, state)
        run_command "vagrant destroy #{state['name']} -f"
        state.delete('name')
      end

      protected

      def load_state(instance)
        vagrantfile = File.join(config['jamie_root'], "Vagrantfile")
        create_vagrantfile(vagrantfile) unless File.exists?(vagrantfile)
        super
      end

      def generate_ssh_args(state)
        Array(state['name'])
      end

      def ssh(ssh_args, cmd)
        run_command %{vagrant ssh #{ssh_args.first} --command '#{cmd}'}
      end

      def create_vagrantfile(vagrantfile)
        File.open(vagrantfile, "wb") { |f| f.write(vagrantfile_contents) }
      end

      def vagrantfile_contents
        arr = []
        arr << %{require 'jamie/vagrant'}
        if File.exists?(File.join(config['jamie_root'], "Berksfile"))
          arr << %{require 'berkshelf/vagrant'}
        end
        arr << %{}
        arr << %{Vagrant::Config.run do |config|}
        arr << %{  Jamie::Vagrant.define_vms(config)}
        arr << %{end\n}
        arr.join("\n")
      end
    end
  end
end

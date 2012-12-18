# -*- encoding: utf-8 -*-

require 'mixlib/shellout'

require 'jamie'

module Jamie

  module Driver

    # Vagrant driver for Jamie. It communicates to Vagrant via the CLI.
    class Vagrant < Jamie::Driver::SSHBase

      default_config 'memory', '256'

      def perform_create(instance, state)
        state['name'] = instance.name
        run "vagrant up #{state['name']} --no-provision"
      end

      def perform_converge(instance, state)
        run "vagrant provision #{state['name']}"
      end

      def perform_destroy(instance, state)
        run "vagrant destroy #{state['name']} -f"
        state.delete('name')
      end

      protected

      def generate_ssh_args(state)
        Array(state['name'])
      end

      def ssh(ssh_args, cmd)
        run %{vagrant ssh #{ssh_args.first} --command '#{cmd}'}
      end

      def run(cmd)
        puts "       [vagrant command] '#{display_cmd(cmd)}'"
        sh = Mixlib::ShellOut.new(cmd, :live_stream => STDOUT,
          :timeout => 60000)
        sh.run_command
        puts "       [vagrant command] ran in #{sh.execution_time} seconds."
        sh.error!
      rescue Mixlib::ShellOut::ShellCommandFailed => ex
        raise ActionFailed, ex.message
      end

      def display_cmd(cmd)
        parts = cmd.partition("\n")
        parts[1] == "\n" ? "#{parts[0]}..." : cmd
      end
    end
  end
end

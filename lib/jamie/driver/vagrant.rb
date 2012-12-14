# -*- encoding: utf-8 -*-

require 'mixlib/shellout'

require 'jamie'

module Jamie

  module Driver

    # Vagrant driver for Jamie. It communicates to Vagrant via the CLI.
    class Vagrant < Jamie::Driver::Base

      default_config 'memory', '256'

      def create(instance)
        run "vagrant up #{instance.name} --no-provision"
      end

      def converge(instance)
        run "vagrant provision #{instance.name}"
      end

      def setup(instance)
        if instance.jr.setup_cmd
          ssh instance, instance.jr.setup_cmd
        else
          super
        end
      end

      def verify(instance)
        if instance.jr.run_cmd
          ssh instance, instance.jr.sync_cmd
          ssh instance, instance.jr.run_cmd
        else
          super
        end
      end

      def destroy(instance)
        run "vagrant destroy #{instance.name} -f"
      end

      private

      def run(cmd)
        puts "       [vagrant command] '#{display_cmd(cmd)}'"
        shellout = Mixlib::ShellOut.new(
          cmd, :live_stream => STDOUT, :timeout => 60000
        )
        shellout.run_command
        puts "       [vagrant command] '#{display_cmd(cmd)}' ran " +
          "in #{shellout.execution_time} seconds."
        shellout.error!
      rescue Mixlib::ShellOut::ShellCommandFailed => ex
        raise ActionFailed, ex.message
      end

      def ssh(instance, cmd)
        run %{vagrant ssh #{instance.name} --command '#{cmd}'}
      end

      def display_cmd(cmd)
        parts = cmd.partition("\n")
        parts[1] == "\n" ? "#{parts[0]}..." : cmd
      end
    end
  end
end

# -*- encoding: utf-8 -*-

require 'mixlib/shellout'

require 'jamie'

module Jamie

  module Driver

    # Vagrant driver for Jamie. It communicates to Vagrant via the CLI.
    class Vagrant < Jamie::Driver::Base

      def create(instance)
        run "echo vagrant up #{instance.name} --no-provision"
      end

      def converge(instance)
        run "echo vagrant provision #{instance.name}"
      end

      def destroy(instance)
        run "echo vagrant destroy #{instance.name} -f"
      end

      private

      def run(cmd)
        puts "       [vagrant command] '#{cmd}'"
        shellout = Mixlib::ShellOut.new(
          cmd, :live_stream => STDOUT, :timeout => 60000
        )
        shellout.run_command
        puts "       [vagrant command] '#{cmd}' ran " +
          "in #{shellout.execution_time} seconds."
        shellout.error!
      rescue Mixlib::ShellOut::ShellCommandFailed => ex
        raise ActionFailed, ex.message
      end
    end
  end
end

require 'forwardable'
require 'vagrant'
require 'vagrant/command/base'

module TestKitchen
  module Runner
    class Vagrant < Base
      extend ::Forwardable

      def_delegator :@command_base, :with_target_vms

      def initialize(env, opts={})
        super
        # TODO: We shouldn't do IO in the constructor
        @command_base = ::Vagrant::Command::Base.new(nil, vagrant_env)
      end

      def provision
        super
        vagrant_env.cli(vagrant_cli_argv('up'))
      end

      def status
        vagrant_env.cli(vagrant_cli_argv('status'))
      end

      def destroy
        vagrant_env.cli(vagrant_cli_argv('destroy'))
      end

      def ssh
        vagrant_env.cli(vagrant_cli_argv('ssh'))
      end

      def with_platforms
        with_target_vms do |vm|
          vm if vm.created?
        end
      end

      def execute_remote_command(vm, command, message=nil)
        vm.ui.info(message, :color => :yellow) if message
        vm.channel.execute(command, :error_check => false) do |type, data|
          next if data =~ /stdin: is not a tty/
          if [:stderr, :stdout].include?(type)
            # Output the data with the proper color based on the stream.
            color = type == :stdout ? :green : :red
            vm.ui.info(data, :color => color, :prefix => false, :new_line => false)
          end
        end
      end

      private

      def vagrant_env
        @vagrant_env ||= begin

          env.create_tmp_file('Vagrantfile',
            IO.read(TestKitchen.source_root.join('config', 'Vagrantfile')))

          options = {
            :ui_class => ::Vagrant::UI::Colored,
            :cwd => env.tmp_path
          }
          env = ::Vagrant::Environment.new(options)
          env.load!
          env
        end
      end

      def vagrant_cli_argv(command)
        argv = [command]
        argv << platform if platform
        argv
      end

    end
  end
end

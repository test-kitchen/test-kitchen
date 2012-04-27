require 'vagrant'
require 'test-kitchen/vagrant'

module TestKitchen
  module Runner
    class Vagrant < Base

      def provision
        super
        vagrant_env.cli(vagrant_cli_argv('up'))
      end

      def test
        vagrant_env.cli(vagrant_cli_argv('tk'))
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

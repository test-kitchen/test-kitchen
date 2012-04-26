require 'vagrant'
require 'test-kitchen/vagrant'

module TestKitchen
  module Runner
    class Vagrant < Base

      def provision
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
        @vagrant_cli ||= begin
          opts = {}
          opts[:ui_class] = ::Vagrant::UI::Colored
          opts[:cwd] = TestKitchen.project_root
          env = ::Vagrant::Environment.new(opts)
          env.load!
          env
        end
      end

      def vagrant_cli_argv(command)
        argv = [command]
        argv << "#{TestKitchen.project_name}-#{platform}" if platform
        argv << "-p" << project if project
        argv
      end
    end
  end
end

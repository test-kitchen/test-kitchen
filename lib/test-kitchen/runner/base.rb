require 'librarian/chef/cli'

module TestKitchen
  module Runner
    class Base

      attr_accessor :platform
      attr_accessor :configuration
      attr_accessor :env

      def initialize(env, options={})
        @env = env
        @platform = options[:platform]
        @configuration = options[:configuration]
      end

      def provision
        assemble_cookbooks!
      end

      def destroy
        raise NotImplementedError
      end

      def run_list
        ['test-kitchen::default']
      end

      def preflight_check
        if env.project.preflight_command
          system(env.project.preflight_command)
          unless $?.success?
            env.ui.info('Your cookbook had lint failures.', :red)
            exit $?.exitstatus
          end
        end
      end

      def test
        runtimes = configuration.runtimes
        runtimes.each do |runtime|
          message = "Synchronizing latest code from source root => test root."
          execute_remote_command(platform, configuration.update_code_command, message)

          message = "Updating dependencies for [#{configuration.name}]"
          message << " under [#{runtime}]" if runtime
          execute_remote_command(platform, configuration.install_command(runtime), message)

          message = "Running tests for [#{configuration.name}]"
          message << " under [#{runtime}]" if runtime
          execute_remote_command(platform, configuration.test_command(runtime), message)
        end
      end

      def status
        raise NotImplementedError
      end

      def destroy
        raise NotImplementedError
      end

      def ssh
        raise NotImplementedError
      end

      def execute_remote_command(platform, command, mesage=nil)
        raise NotImplementedError
      end

      def self.inherited(subclass)
        key = subclass.to_s.split('::').last.downcase
        Runner.targets[key] = subclass
      end

      protected

      def assemble_cookbooks!
        # dump out a meta Cheffile
        env.create_tmp_file('Cheffile',
            IO.read(TestKitchen.source_root.join('config', 'Cheffile')))

        env.ui.info("Assembling required cookbooks at [#{env.tmp_path.join('cookbooks')}].", :yellow)

        # The following is a programatic version of `librarian-chef install`
        Librarian::Action::Clean.new(librarian_env).run
        Librarian::Action::Resolve.new(librarian_env).run
        Librarian::Action::Install.new(librarian_env).run
      end

      def librarian_env
        @librarian_env ||= Librarian::Chef::Environment.new(:project_path => env.tmp_path)
      end
    end

    def self.targets
      @@targets ||= {}
    end
  end
end

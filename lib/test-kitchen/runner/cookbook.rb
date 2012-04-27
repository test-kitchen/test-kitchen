require 'vagrant'
require 'test-kitchen/environment'

module TestKitchen
  module Runner
    class Cookbook

      Runner.targets['cookbook'] = TestKitchen::Runner::Cookbook
      attr_writer :runner

      def initialize(env, opts={})
        raise ArgumentError, 'Environment must be provided' unless env
        @env = env
        @opts = opts
      end

      def runner
        @runner ||= Runner.targets['vagrant'].new(@env, @opts)
      end

      def method_missing(meth, *args)
        runner.send(meth, *args)
      end

      def respond_to?(meth, include_private = false)
        runner.respond_to?(meth, include_private)
      end

      def test
        project_name = File.basename(@env.root_path)
        lint_cookbook(project_name, @env.root_path)
        project = TestKitchen::Project.new(project_name)
        project.install = 'bundle install'
        project.script = 'bundle exec cucumber'
        @env.projects << project
        runner.test
      end

      private

      def lint_cookbook(cookbook_name, cookbook_path)
        parent_dir = File.join(cookbook_path, '..')
        die_unless "knife cookbook test -o #{parent_dir} #{cookbook_name}"
        die_unless "foodcritic -f correctness #{cookbook_path}"
      end

      def die_unless(cmd)
        system(cmd)
        exit $?.exitstatus unless $?.success?
      end

    end
  end
end

require 'vagrant'
require 'test-kitchen/vagrant'

module TestKitchen
  module Runner
    class Cookbook < Base

      def initialize(opts={})
        super(opts)
        @runner = Runner.targets['vagrant'].new(opts)
      end

      [:provision, :status, :destroy, :ssh].each do |cmd|
        define_method(cmd) do
          @runner.send(cmd)
        end
      end

      def test
        lint_cookbook(TestKitchen.project_name, TestKitchen.project_root)
        project = TestKitchen::Project.new(TestKitchen.project_name)
        project.install = 'bundle install'
        project.script = 'bundle exec cucumber'
        TestKitchen.projects << project
        @runner.test
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

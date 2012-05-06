module TestKitchen
  module Project
    class Cookbook < Ruby

      attr_writer :lint
      attr_accessor :supported_platforms

      def initialize(name, &block)
        super(name, &block)
        @supported_platforms = []
      end

      def lint(arg=nil)
        set_or_return(:lint, arg, {:default => true})
      end

      def language(arg=nil)
        "chef"
      end

      def preflight_command(runtime = nil)
        return nil unless lint
        parent_dir = File.join(root_path, '..')
        cmd = "knife cookbook test -o #{parent_dir} #{name}"
        cmd << "&& foodcritic -f ~FC007 -f correctness #{root_path}"
        cmd
      end

      def install_command(runtime=nil)
        "sudo gem update --system; gem install bundler && #{cd} && #{path} bundle install"
      end

      def test_command(runtime=nil)
        %q{#{cd} && if [ -d "features" ]; then #{path} bundle exec cucumber -t @#{name} features; fi}
      end

      def each_build(platforms, &block)
        super(platforms.select do |platform|
          supported_platforms.any? do |supported|
            platform.start_with?("#{supported}-")
          end
        end, &block)
      end

      private

      def cd
        "cd #{File.join(guest_test_root, 'test')}"
      end

      def path
        'PATH=$PATH:/var/lib/gems/1.8/bin'
      end

    end
  end
end

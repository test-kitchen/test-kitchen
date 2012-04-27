require 'librarian/chef/cli'

module TestKitchen
  module Runner
    class Base

      attr_accessor :platform
      attr_accessor :project

      def initialize(opts={})
        @platform = opts[:platform]
        @project = opts[:project]
      end

      def provision
        assemble_cookbooks!
      end

      def test
        raise NotImplementedError
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

      def self.inherited(subclass)
        key = subclass.to_s.split('::').last.downcase
        Runner.targets[key] = subclass
      end

      def assemble_cookbooks!
        FileUtils.mkdir_p(TestKitchen.project_tmp)
        # dump out a meta Cheffile
        unless File.exists?(File.join(TestKitchen.project_tmp, 'Cheffile'))
          File.open(File.join(TestKitchen.project_tmp, 'Cheffile'), 'w') do |f|
            f.write(IO.read(File.join(TestKitchen.source_root, 'config', 'Cheffile')))
          end
        end

        # let Librarian do it's thing
        require 'librarian/chef/cli'
        Librarian::Chef::Cli.bin!
      end
    end

    def self.targets
      @@targets ||= {}
    end
  end
end

require 'test-kitchen'

module TestKitchen

  module Project
    describe Cookbook do
      describe "#each_build" do
        it "yields only supported platforms" do
          cookbook = Cookbook.new('example')
          cookbook.supported_platforms = %w{ubuntu centos}
          actual_matrix = []
          cookbook.each_build(%w{beos-5.0 centos-5.0 centos-6.2}) do |platform,configuration|
            actual_matrix << [platform, configuration]
          end
          actual_matrix.must_equal([
            ['centos-5.0', cookbook],
            ['centos-6.2', cookbook]
          ])
        end
      end
    end
  end
end

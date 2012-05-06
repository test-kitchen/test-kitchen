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
    describe "#extract_supported_platforms" do
      let(:cookbook) { Cookbook.new('example') }
      it "raises if no metadata is provided" do
        lambda { cookbook.extract_supported_platforms }.must_raise ArgumentError
      end
      it "raises if the metadata is nil" do
        lambda { cookbook.extract_supported_platforms(nil) }.must_raise ArgumentError
      end
      it "returns an empty if the metadata does not parse" do
        cookbook.extract_supported_platforms(%q{
          <%= not_ruby_code %>
        }).must_be_empty
      end
      it "returns an empty if the metadata does not specify platforms" do
        cookbook.extract_supported_platforms(%q{
          maintainer       "Example Person"
          maintainer_email "example@example.org"
          license          "All rights reserved"
          description      "Installs/Configures example"
          long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
          version          "0.0.1"
        }).must_be_empty
      end
      it "returns the name of the supported platforms" do
        cookbook.extract_supported_platforms(%q{
          maintainer       "Example Person"
          maintainer_email "example@example.org"
          license          "All rights reserved"
          description      "Installs/Configures example"
          long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
          version          "0.0.1"
          supports         "ubuntu"
          supports         "centos"
        }).must_equal(%w{ubuntu centos})
      end
      it "returns the name of the supported platforms for a word list" do
        cookbook.extract_supported_platforms(%q{
          maintainer       "Example Person"
          maintainer_email "example@example.org"
          license          "All rights reserved"
          description      "Installs/Configures example"
          long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
          version          "0.0.1"
          %w{centos ubuntu debian}.each do |os|
            supports os
          end
        }).must_equal(%w{centos ubuntu debian})
      end
    end
  end
end

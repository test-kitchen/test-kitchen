require_relative '../../spec_helper'

require 'test-kitchen'

module TestKitchen

  module Project
    describe Ruby do
      describe "#install_command" do
        it "runs bundle install in the project directory" do
          project = Ruby.new('foo')
          project.install_command.must_equal 'cd /test-kitchen/test && bundle install'
        end
        it "uses rvm to switch to the selected runtime" do
          project = Ruby.new('foo')
          project.install_command('1.9.3').must_equal 'cd /test-kitchen/test && rvm use 1.9.3 && bundle install'
        end
      end
      describe "#test_command" do
        it "runs the install script in the project directory" do
          project = Ruby.new('foo')
          project.test_command.must_equal 'cd /test-kitchen/test && rspec spec'
        end
        it "runs the test script under the correct runtime" do
          project = Ruby.new('foo')
          project.test_command('1.9.3').must_equal 'cd /test-kitchen/test && rvm use 1.9.3 && rspec spec'
        end
      end
      describe "#runtimes" do
        it "defaults to ruby 1.9.2 if the language is ruby" do
          project = Ruby.new('foo')
          project.language = 'ruby'
          project.runtimes.must_equal ['1.9.2']
        end
      end
    end
  end
end

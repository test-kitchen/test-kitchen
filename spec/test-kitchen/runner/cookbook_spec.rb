require File.expand_path('../../../spec_helper', __FILE__)
require 'test-kitchen'
require 'test-kitchen/runner'

module TestKitchen::Runner

  describe Cookbook do

    describe "#initialize" do
      it "raises if the environment is not provided" do
        lambda{ Cookbook.new(nil) }.must_raise(ArgumentError)
      end
      it "registers itself as an available runner" do
        TestKitchen::Runner.targets.must_include 'cookbook'
      end
    end
    describe "nested runner" do
      it "forwards messages to a nested runner" do
        cookbook_runner = Cookbook.new(TestKitchen::Environment.new)
        nested_runner = MiniTest::Mock.new
        nested_runner.expect :send, false, [:provision]
        cookbook_runner.runner = nested_runner
        cookbook_runner.provision
      end
      it "uses a vagrant runner if one is not explicitly set" do
        cookbook_runner = Cookbook.new(TestKitchen::Environment.new)
        cookbook_runner.runner.class.must_equal Vagrant
      end
    end
    describe "#respond_to?" do
      it "claims to respond to standard runner methods" do
        cookbook_runner = Cookbook.new(TestKitchen::Environment.new)
        [:provision, :destroy, :ssh].each{|meth| cookbook_runner.must_respond_to meth}
      end
    end

  end

end

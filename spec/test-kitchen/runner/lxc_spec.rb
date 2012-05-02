require_relative '../../spec_helper'

require 'test-kitchen'

module TestKitchen

  module Runner
    describe LXC do
      describe "#initialize" do
        it "complains if an environent is not provided" do
          lambda { Environment.new }.must_raise ArgumentError
        end
        it "accepts an environment as a constructor argument" do
          env = Environment.new(:ignore_kitchenfile => true)
          runner = LXC.new(env)
          runner.env.must_equal env
          runner.options.must_equal({})
        end
        it "optionally accepts a options too" do
          env = Environment.new(:ignore_kitchenfile => true)
          runner = LXC.new(env, {:platform => 'ubuntu'})
          runner.env.must_equal env
          runner.options.must_equal({:platform => 'ubuntu'})
        end
      end
      describe "#nested_runner" do
        it "wraps a nested runner which acts as the LXC host" do
          env = Environment.new(:ignore_kitchenfile => true)
          runner = LXC.new(env, {:platform => 'ubuntu'})
          runner.nested_runner = 'foo'
          runner.nested_runner.must_equal 'foo'
        end
        it "defaults the nested runner to using vagrant" do
          skip "Vagrant runner is not test friendly"
        end
        it "sets the host platform to natty" do
          skip "Vagrant runner is not test friendly"
        end
      end
      describe "#provision" do
        let(:runner) do
          env = Environment.new(:ignore_kitchenfile => true)
          runner = LXC.new(env, {:platform => 'ubuntu'})
        end
        it "delegates the provision call to the nested runner" do
          runner.nested_runner = MiniTest::Mock.new
          runner.nested_runner.expect :provision, nil
          runner.nested_runner.expect :with_target_vms, nil, [String]
          runner.provision
          runner.nested_runner.verify
        end
      end
      describe "#run_list" do
        it "expresses the dependency on the LXC recipe" do
          env = Environment.new(:ignore_kitchenfile => true)
          runner = LXC.new(env, {:platform => 'ubuntu'})
          runner.run_list.must_include 'test-kitchen::lxc'
        end
      end
    end
  end
end

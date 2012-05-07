require_relative '../spec_helper'

require 'test-kitchen'
require 'test-kitchen/dsl'

module TestKitchen::DSL

  module Helper
    def dsl_instance(dsl_module)
      Class.new do
        include dsl_module
        def env
          TestKitchen::Environment.new(:ignore_kitchenfile => true)
        end
      end.new
    end
  end

  describe BasicDSL do
    include Helper
    let(:dsl) { dsl_instance(BasicDSL) }
    it "allows an integration test to be defined" do
      dsl.integration_test('private_chef').wont_be_nil
    end
    it "sets the project name" do
      dsl.integration_test('private_chef').name.must_equal 'private_chef'
    end
    it "allows the language to be set" do
      project = dsl.integration_test 'private_chef' do
        language 'erlang'
      end
      project.language.must_equal 'erlang'
    end
    it "allows the install command to be set" do
      project = dsl.integration_test 'private_chef' do
        install 'make install'
      end
      project.install.must_equal 'make install'
    end
    it "defaults to running unit tests if available" do
      assert(dsl.integration_test('private_chef') do
      end.specs)
    end
    it "can prevent units tests from being run" do
      refute(dsl.integration_test('private_chef') do
        specs false
      end.specs)
    end
    it "defaults to running cucumber features if available" do
      assert(dsl.integration_test('private_chef') do
      end.features)
    end
    it "can prevent cucumber features from being run" do
      refute(dsl.integration_test('private_chef') do
        features false
      end.features)
    end
    it "allows tests to be selectively disabled for individual configurations" do
      project = dsl.integration_test('private_chef') do
        configuration "client" do
          specs false
          features false
        end
        configuration "server"
      end
      assert project.specs
      assert project.features
      refute project.configurations['client'].specs
      refute project.configurations['client'].features
      assert project.configurations['server'].specs
      assert project.configurations['server'].features
    end
    it "allows platforms to be defined" do
      dsl.platform :ubuntu do
        version '10.04' do
          box "ubuntu-10.04"
          box_url "http://example.org/ubuntu-10.04.box"
          lxc_url "http://example.org/ubuntu-10.04.tar.gz"
        end
      end
    end
  end

  describe CookbookDSL do
    include Helper
    let(:dsl) { dsl_instance(CookbookDSL) }
    it "allows an cookbook project to be defined" do
      dsl.cookbook('mysql').wont_be_nil
      dsl.cookbook('mysql').name.must_equal 'mysql'
    end
    it "can set the lint check to disabled" do
      refute(dsl.cookbook('mysql') do
        lint false
      end.lint)
    end
    it "can specify arguments for the lint check" do
      lint = dsl.cookbook('mysql') do
        lint(:tags => %w{correctness style}, :include_rules => '/custom/rules')
      end.lint
      assert(lint)
      lint[:tags].must_equal ['correctness', 'style']
      lint[:include_rules].must_equal '/custom/rules'
    end
    it "can specify configurations additively" do
      dsl.cookbook('mysql') do
        configuration 'client'
        configuration 'server'
      end.configurations.values.map(&:name).must_equal %w{client server}
    end
    it "can specify exclusions" do
      dsl.cookbook('mysql') do
        configuration 'client'
        configuration 'server'
        exclude :platform => 'amazon'
      end.exclusions.must_equal([{:platform => 'amazon'}])
    end
    it "can specify configuration-specific exclusions" do
      dsl.cookbook('mysql') do
        configuration 'client'
        configuration 'server'
        exclude :platform => 'amazon', :configuration => 'server'
      end.exclusions.must_equal([{:platform => 'amazon',
        :configuration => 'server'}])
    end
    it "can specify exclusions additively" do
      dsl.cookbook('mysql') do
        configuration 'client'
        configuration 'server'
        exclude :platform => 'amazon', :configuration => 'server'
        exclude :platform => 'freebsd'
      end.exclusions.must_equal([{:platform => 'amazon',
        :configuration => 'server'}, {:platform => 'freebsd'}])
    end
  end

end

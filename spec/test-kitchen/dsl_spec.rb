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
    it "can specify configurations additively" do
      dsl.cookbook('mysql') do
        configuration 'client'
        configuration 'server'
      end.configurations.map(&:name).must_equal %w{client server}
    end
    it "can specify exclusions additively" do
      dsl.cookbook('mysql') do
        configuration 'client'
        configuration 'server'
        exclude :platform => 'amazon'
      end.platforms.wont_include 'amazon'
    end
  end

end

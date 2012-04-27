require_relative '../spec_helper'

require 'test-kitchen'

describe TestKitchen::Project do

  describe "#initialize" do
    it "raises if a name is not provided" do
      lambda{ TestKitchen::Project.new(nil) }.must_raise(ArgumentError)
    end
    it "raises if the name is empty" do
      lambda{ TestKitchen::Project.new('') }.must_raise(ArgumentError)
    end
  end
  describe "#language" do
    it "defaults to ruby" do
      TestKitchen::Project.new('foo').language.must_equal 'ruby'
    end
    it "can be set to erlang" do
      project = TestKitchen::Project.new('foo')
      project.language = 'erlang'
      project.language.must_equal 'erlang'
    end
  end
  describe "#install" do
    it "defaults to bundle install when you are using ruby" do
      project = TestKitchen::Project.new('foo')
      project.language = 'ruby'
      project.install.must_equal 'bundle install'
    end
    it "defaults to empty string when you are not using ruby" do
      project = TestKitchen::Project.new('foo')
      project.language = 'erlang'
      project.install.must_equal ''
    end
    it "can be set to an arbitrary command" do
      project = TestKitchen::Project.new('foo')
      project.install = 'make install'
      project.install.must_equal 'make install'
    end
  end
  describe "#script" do
    it "defaults to running rspec" do
      TestKitchen::Project.new('foo').script.must_equal 'rspec spec'
    end
  end
  describe "#runtimes" do
    it "defaults to ruby 1.9.2 if the language is ruby" do
      project = TestKitchen::Project.new('foo')
      project.language = 'ruby'
      project.runtimes.must_equal ['1.9.2']
    end
    it "returns the rvm runtime value if the language is ruby" do
      project = TestKitchen::Project.new('foo')
      project.language = 'ruby'
      project.rvm = ['1.9.3']
      project.runtimes.must_equal ['1.9.3']
    end
    it "returns an empty if the language is not supported" do
      project = TestKitchen::Project.new('foo')
      project.language = 'erlang'
      project.runtimes.must_be_empty
    end
  end

end

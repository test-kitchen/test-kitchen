# -*- encoding: utf-8 -*-

require 'simplecov'
SimpleCov.adapters.define 'gem' do
  command_name 'Specs'

  add_filter '/spec/'
  add_filter '/lib/vendor/'

  add_group 'Libraries', '/lib/'
end
SimpleCov.start 'gem'

require 'minitest/autorun'

require 'jamie'

describe Jamie::Suite do

  let(:opts) do ; { 'name' => 'suitezy', 'run_list' => [ 'doowah' ] } ; end
  let(:suite) { Jamie::Suite.new(opts) }

  it "raises an ArgumentError if name is missing" do
    opts.delete('name')
    proc { Jamie::Suite.new(opts) }.must_raise ArgumentError
  end

  it "raises an ArgumentError if run_list is missing" do
    opts.delete('run_list')
    proc { Jamie::Suite.new(opts) }.must_raise ArgumentError
  end

  it "returns an empty Hash given no attributes" do
    suite.attributes.must_equal Hash.new
  end

  it "returns nil given no data_bags_path" do
    suite.data_bags_path.must_be_nil
  end

  it "returns nil given no roles_path" do
    suite.roles_path.must_be_nil
  end

  it "returns attributes from constructor" do
    opts.merge!({ 'attributes' => { 'a' => 'b' }, 'data_bags_path' => 'crazy',
                  'roles_path' => 'town' })
    suite.name.must_equal 'suitezy'
    suite.run_list.must_equal [ 'doowah' ]
    suite.attributes.must_equal({ 'a' => 'b' })
    suite.data_bags_path.must_equal 'crazy'
    suite.roles_path.must_equal 'town'
  end
end

describe Jamie::Platform do

  let(:opts) do ; { 'name' => 'plata', 'driver' => 'imadriver' } ; end
  let(:platform) { Jamie::Platform.new(opts) }

  it "raises an ArgumentError if name is missing" do
    opts.delete('name')
    proc { Jamie::Platform.new(opts) }.must_raise ArgumentError
  end

  it "raises an ArgumentError if driver is missing" do
    opts.delete('driver')
    proc { Jamie::Platform.new(opts) }.must_raise ArgumentError
  end

  it "returns an empty Array given no run_list" do
    platform.run_list.must_equal []
  end

  it "returns an empty Hash given no attributes" do
    platform.attributes.must_equal Hash.new
  end

  it "returns attributes from constructor" do
    opts.merge!({ 'run_list' => [ 'a', 'b' ], 'attributes' => { 'c' => 'd' }})
    platform.name.must_equal 'plata'
    platform.driver.must_equal 'imadriver'
    platform.run_list.must_equal [ 'a', 'b' ]
    platform.attributes.must_equal({ 'c' => 'd' })
  end
end

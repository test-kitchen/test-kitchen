# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../spec_helper"

require "kitchen/errors"
require "kitchen/state_file"
require "kitchen/util"

class YamledState
  attr_accessor :yoinks
end

describe Kitchen::StateFile do

  let(:state_file)  { Kitchen::StateFile.new("/tmp", "oftheunion") }
  let(:file_name)   { "/tmp/.kitchen/oftheunion.yml" }

  before do
    FakeFS.activate!
    FileUtils.mkdir_p("/tmp")
  end

  after do
    FakeFS.deactivate!
    FakeFS::FileSystem.clear
  end

  describe "#read" do

    it "returns an empty hash if the file does not exist" do
      state_file.read.must_equal(Hash.new)
    end

    it "returns a Hash with symbolized keys from the state file" do
      stub_state_file!

      state_file.read.must_equal(
        :cloud_id => 42,
        :flavor => "extra_crispy"
      )
    end

    it "arbitrary objects aren't deserialized from state file" do
      stub_state_file! <<-'YAML'.gsub(/^ {8}/, "")
        --- !ruby/object:YamledState
        yoinks: zoinks
      YAML

      state_file.read.class.wont_equal YamledState
      state_file.read.class.must_equal Hash
      state_file.read.must_equal(:yoinks => "zoinks")
    end

    it "raises a StateFileLoadError if the state file cannot be parsed" do
      stub_state_file!("&*%^*")

      proc { state_file.read }.must_raise Kitchen::StateFileLoadError
    end
  end

  describe "#write" do

    it "creates the directory path to the state file" do
      File.directory?("/tmp/.kitchen").must_equal false
      state_file.write({})
      File.directory?("/tmp/.kitchen").must_equal true
    end

    it "writes a state file with stringified keys" do
      state_file.write(:thekey => "thyself")

      IO.read(file_name).split("\n").must_include "thekey: thyself"
    end
  end

  describe "#destroy" do

    it "executes if no file exists" do
      File.exist?(file_name).must_equal false
      state_file.destroy
      File.exist?(file_name).must_equal false
    end

    it "deletes the state file" do
      stub_state_file!
      state_file.destroy

      File.exist?(file_name).must_equal false
    end
  end

  private

  def stub_state_file!(yaml_string = nil)
    if yaml_string.nil?
      yaml_string = <<-'YAML'.gsub(/^ {8}/, "")
        ---
        cloud_id: 42
        flavor: extra_crispy
      YAML
    end

    FileUtils.mkdir_p(File.dirname(file_name))
    File.open(file_name, "wb") { |f| f.write(yaml_string) }
  end
end

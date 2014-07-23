# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2014, Fletcher Nichol
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

require "kitchen/diagnostic"

describe Kitchen::Diagnostic do

  let(:loader) do
    stub(:diagnose => { :who => "loader" })
  end

  let(:instances) do
    [
      stub(:name => "i1", :diagnose => { :stuff => "sup" }),
      stub(:name => "i2", :diagnose => { :stuff => "yo" })
    ]
  end

  it "#read returns a Hash" do
    Kitchen::Diagnostic.new.read.must_be_instance_of Hash
  end

  it "#read returns the version of Test Kitchen" do
    Kitchen::Diagnostic.new.read["kitchen_version"].must_equal Kitchen::VERSION
  end

  it "#read returns a timestamp in UTC" do
    Time.stubs(:now).returns(Time.at(0))

    Kitchen::Diagnostic.new.read["timestamp"].
      must_equal "1970-01-01 00:00:00 UTC"
  end

  it "#read doesn't return a loader hash if not given one" do
    Kitchen::Diagnostic.new.read.key?("loader").must_equal false
  end

  it "#read returns the loader's diganose hash if a loader is present" do
    Kitchen::Diagnostic.new(:loader => loader).
      read["loader"].must_equal("who" => "loader")
  end

  it "#read returns an error hash for loader if error hash is passed in" do
    Kitchen::Diagnostic.new(:loader => { :error => "damn" }).
      read["loader"].must_equal("error" => "damn")
  end

  it "#read returns an empty hash if no instances were given" do
    Kitchen::Diagnostic.new.read["instances"].must_equal Hash.new
  end

  it "#read returns the instances' diganose hashes if instances are present" do
    Kitchen::Diagnostic.new(:instances => instances).
      read["instances"].
      must_equal("i1" => { "stuff" => "sup" }, "i2" => { "stuff" => "yo" })
  end

  it "#read returns an error hash for instances if error hash is passed in" do
    Kitchen::Diagnostic.new(:instances => { :error => "shoot" }).
      read["instances"].must_equal("error" => "shoot")
  end
end

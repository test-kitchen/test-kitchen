# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2012, Fletcher Nichol
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

require_relative '../spec_helper'

describe Jamie::Instance do

  let(:suite) do
    Jamie::Suite.new({ :name => 'suite',
      :run_list => 'suite_list', :attributes => { :s => 'ss' } })
  end

  let(:platform) do
    Jamie::Platform.new({ :name => 'platform',
      :run_list => 'platform_list', :attributes => { :p => 'pp' } })
  end

  let(:driver) { Jamie::Driver::Dummy.new({}) }

  let(:jr) { Jamie::Jr.new(suite.name) }

  let(:opts) do
    { :suite => suite, :platform => platform, :driver => driver, :jr => jr }
  end

  let(:instance) { Jamie::Instance.new(opts) }

  before do
    Celluloid.logger = Logger.new(StringIO.new)
  end

  it "raises an ArgumentError if suite is missing" do
    opts.delete(:suite)
    proc { Jamie::Instance.new(opts) }.must_raise Jamie::ClientError
  end

  it "raises an ArgumentError if platform is missing" do
    opts.delete(:platform)
    proc { Jamie::Instance.new(opts) }.must_raise Jamie::ClientError
  end

  it "returns suite" do
    instance.suite.must_equal suite
  end

  it "returns platform" do
    instance.platform.must_equal platform
  end

  it "returns an instance of Jr" do
    instance.jr.must_be_instance_of Jamie::Jr
  end

  describe "#name" do

    def combo(suite_name, platform_name)
      opts[:suite] = Jamie::Suite.new(
        :name => suite_name, :run_list => []
      )
      opts[:platform] = Jamie::Platform.new(
        :name => platform_name
      )
      Jamie::Instance.new(opts)
    end

    it "combines the suite and platform names with a dash" do
      combo('suite', 'platform').name.must_equal "suite-platform"
    end

    it "squashes periods" do
      combo('suite.ness', 'platform').name.must_equal "suiteness-platform"
      combo('suite', 'platform.s').name.must_equal "suite-platforms"
      combo('s.s.', '.p.p').name.must_equal "ss-pp"
    end

    it "transforms underscores to dashes" do
      combo('suite_ness', 'platform').name.must_equal "suite-ness-platform"
      combo('suite', 'platform-s').name.must_equal "suite-platform-s"
      combo('_s__s_', 'pp_').name.must_equal "-s--s--pp-"
    end
  end

  describe "#run_list" do

    def combo(suite_list, platform_list)
      opts[:suite] = Jamie::Suite.new(
        :name => 'suite', :run_list => suite_list
      )
      opts[:platform] = Jamie::Platform.new(
        :name => 'platform', :run_list => platform_list
      )
      Jamie::Instance.new(opts)
    end

    it "combines the platform then suite run_lists" do
      combo(%w{s1 s2}, %w{p1 p2}).run_list.must_equal %w{p1 p2 s1 s2}
    end

    it "uses the suite run_list only when platform run_list is empty" do
      combo(%w{sa sb}, nil).run_list.must_equal %w{sa sb}
    end

    it "returns an emtpy Array if both run_lists are empty" do
      combo([], nil).run_list.must_equal []
    end
  end

  describe "#attributes" do

    def combo(suite_attrs, platform_attrs)
      opts[:suite] = Jamie::Suite.new(
        :name => 'suite', :run_list => [], :attributes => suite_attrs
      )
      opts[:platform] = Jamie::Platform.new(
        :name => 'platform', :attributes => platform_attrs
      )
      Jamie::Instance.new(opts)
    end

    it "merges suite and platform hashes together" do
      combo(
        { :suite => { :s1 => 'sv1' } },
        { :suite => { :p1 => 'pv1' }, :platform => 'pp' }
      ).attributes.must_equal({
        :suite => { :s1 => 'sv1', :p1 => 'pv1' },
        :platform => 'pp'
      })
    end

    it "merges suite values over platform values" do
      combo(
        { :common => { :c1 => 'xxx' } },
        { :common => { :c1 => 'cv1', :c2 => 'cv2' } },
      ).attributes.must_equal({
          :common => { :c1 => 'xxx', :c2 => 'cv2' }
        })
    end
  end

  it "#dna combines attributes with the run_list" do
    instance.dna.must_equal({ :s => 'ss', :p => 'pp',
      :run_list => ['platform_list', 'suite_list'] })
  end
end

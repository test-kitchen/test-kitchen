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

require "kitchen/metadata_chopper"

describe Kitchen::MetadataChopper do

  before do
    FakeFS.activate!
    FileUtils.mkdir_p("/tmp")
  end

  after do
    FakeFS.deactivate!
    FakeFS::FileSystem.clear
  end

  let(:described_class) { Kitchen::MetadataChopper }

  describe ".new" do

    it "contains a :name attribute" do
      stub_metadata!("banzai")

      described_class.new("/tmp/metadata.rb")[:name].must_equal "banzai"
    end

    it "contains a :version attribute" do
      stub_metadata!("foobar", "1.2.3")

      described_class.new("/tmp/metadata.rb")[:version].must_equal "1.2.3"
    end
  end

  describe ".extract" do

    it "returns a tuple" do
      stub_metadata!("foo", "1.2.3")

      described_class.extract("/tmp/metadata.rb").must_equal ["foo", "1.2.3"]
    end

    it "returns nils for a name or version that isn't present" do
      File.open("/tmp/metadata.rb", "wb") do |f|
        f.write %{maintainer       "Michael Bluth"\n}
      end

      described_class.extract("/tmp/metadata.rb").must_equal [nil, nil]
    end
  end

  def stub_metadata!(name = "foobar", version = "5.2.1")
    File.open("/tmp/metadata.rb", "wb") do |f|
      f.write <<-METADATA_RB.gsub(/^ {8}/, "")
        name             "#{name}"
        maintainer       "Michael Bluth"
        maintainer_email "michael@bluth.com"
        license          "Apache 2.0"
        description      "Doing stuff!"
        long_description "Doing stuff!"
        version          "#{version}"
      METADATA_RB
    end
  end
end

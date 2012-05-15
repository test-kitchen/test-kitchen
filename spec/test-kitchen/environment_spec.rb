#
# Author:: Andrew Crump (<andrew@kotirisoftware.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative '../spec_helper'

require 'test-kitchen'

module TestKitchen
  describe Environment do
    describe "#initialize" do
      it "accepts an additional custom name for the kitchen file" do
        env = Environment.new({:kitchenfile_name => 'Cucinafile', :ignore_kitchenfile => true})
        env.kitchenfile_name.must_equal ['Cucinafile', 'Kitchenfile', 'kitchenfile']
      end
      it "accepts an additional custom name for the kitchen file as an array" do
        env = Environment.new({:kitchenfile_name => ['Cucinafile', 'cucinafile'], :ignore_kitchenfile => true})
        env.kitchenfile_name.must_equal ['Cucinafile', 'cucinafile', 'Kitchenfile', 'kitchenfile']
      end
      it "raises if the kitchenfile could not be located" do
        lambda { env = Environment.new }.must_raise(ArgumentError)
      end
      it "doesn't raise if the kitchenfile should be ignored" do
        env = Environment.new({:ignore_kitchenfile => true})
      end
      it "sets the temp scratch directory to a path under the root directory" do
        env = Environment.new({:ignore_kitchenfile => true})
        env.tmp_path.to_s.must_equal(File.join(env.root_path, '.kitchen'))
      end
      it "sets the cache directory to a path under the temporary directory" do
        env = Environment.new({:ignore_kitchenfile => true})
        env.cache_path.to_s.must_equal(File.join(env.tmp_path, '.cache'))
      end
    end
    describe "loading config" do
      let(:env) do
        env = Environment.new({:ignore_kitchenfile => true})
      end
      it "does not claim to be loaded until the config has actually been loaded" do
        refute env.loaded?
      end
      it "reports it is loaded if the config has been loaded" do
        env.load! # Why is this a bang operator?
        assert env.loaded?
      end
      it "supports chaining on load" do
        assert env.load!.loaded?
      end
    end
    describe "platforms" do
      let(:env) do
        env = Environment.new({:ignore_kitchenfile => true})
        env.platforms['ubuntu'] = Platform.new(:ubuntu) do
          version '10.04' do
            box "ubuntu-10.04"
            box_url "http://example.org/ubuntu-10.04.box"
          end
          version '11.04' do
            box "ubuntu-11.04"
            box_url "http://example.org/ubuntu-11.04.box"
          end
        end
        env
      end
      describe "#all_platforms" do
        it "flattens the nested platforms to a hash" do
          env.all_platforms.keys.must_equal(['ubuntu-10.04', 'ubuntu-11.04'])
          env.all_platforms['ubuntu-10.04'].wont_be_nil
          env.all_platforms['ubuntu-11.04'].wont_be_nil
        end
      end
      describe "#platform_names" do
        it "returns a list of platform names" do
          env.platform_names.must_equal(['ubuntu-10.04', 'ubuntu-11.04'])
        end
      end
    end
  end
end

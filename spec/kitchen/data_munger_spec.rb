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

require_relative '../spec_helper'

require 'kitchen/data_munger'

module Kitchen

  describe DataMunger do

    DATA_KEYS = {
      :driver => :name,
      :provisioner => :name,
      :busser => :version
    }

    DATA_KEYS.each_pair do |key, default_key|

      describe "##{key}" do

        describe "from single source" do

          it "returns empty hash if no common #{key} hash is provided" do
            DataMunger.new({
            }).public_send(key, "suite", "platform").must_equal({})
          end

          it "returns common #{key} name" do
            DataMunger.new({
              key => "starship"
            }).public_send(key, "suite", "platform").must_equal({
              default_key => "starship"
            })
          end

          it "returns common #{key} config" do
            DataMunger.new({
              key => {
                default_key => "starship",
                :speed => 42
              }
            }).public_send(key, "suite", "platform").must_equal({
              default_key => "starship",
              :speed => 42
            })
          end

          it "returns empty hash if platform config doesn't have #{key} hash" do
            DataMunger.new({
              :platforms => [
                { :name => "plat" }
              ]
            }).public_send(key, "suite", "plat").must_equal({})
          end

          it "returns platform #{key} name" do
            DataMunger.new({
              :platforms => [
                {
                  :name => "plat",
                  key => "flip"
                }
              ]
            }).public_send(key, "suite", "plat").must_equal({
              default_key => "flip"
            })
          end

          it "returns platform config containing #{key} hash" do
            DataMunger.new({
              :platforms => [
                {
                  :name => "plat",
                  key => {
                    default_key => "flip",
                    :flop => "yep"
                  }
                }
              ]
            }).public_send(key, "suite", "plat").must_equal({
              default_key => "flip",
              :flop => "yep"
            })
          end

          it "returns empty hash if suite config doesn't have #{key} hash" do
            DataMunger.new({
              :suites => [
                { :name => "sweet" }
              ]
            }).public_send(key, "sweet", "platform").must_equal({})
          end

          it "returns suite #{key} name" do
            DataMunger.new({
              :suites => [
                {
                  :name => "sweet",
                  key => "waz"
                }
              ]
            }).public_send(key, "sweet", "platform").must_equal({
              default_key => "waz"
            })
          end

          it "returns suite config containing #{key} hash" do
            DataMunger.new({
              :suites => [
                {
                  :name => "sweet",
                  key => {
                    default_key => "waz",
                    :up => "nope"
                  }
                }
              ]
            }).public_send(key, "sweet", "platform").must_equal({
              default_key => "waz",
              :up => "nope"
            })
          end
        end

        describe "from multiple sources merging" do

          it "suite into platform into common" do
            DataMunger.new({
              key => {
                default_key => "commony",
                :color => "purple",
                :fruit => ["apple", "pear"],
                :deep => { :common => "junk" }
              },
              :platforms => [
                {
                  :name => "plat",
                  key => {
                    default_key => "platformy",
                    :fruit => ["banana"],
                    :deep => { :platform => "stuff" }
                  }
                }
              ],
              :suites => [
                {
                  :name => "sweet",
                  key => {
                    default_key => "suitey",
                    :vehicle => "car",
                    :deep => { :suite => "things" }
                  }
                }
              ]
            }).public_send(key, "sweet", "plat").must_equal({
              default_key => "suitey",
              :color => "purple",
              :fruit => ["banana"],
              :vehicle => "car",
              :deep => {
                :common => "junk",
                :platform => "stuff",
                :suite => "things"
              }
            })
          end

          it "platform into common" do
            DataMunger.new({
              key => {
                default_key => "commony",
                :color => "purple",
                :fruit => ["apple", "pear"],
                :deep => { :common => "junk" }
              },
              :platforms => [
                {
                  :name => "plat",
                  key => {
                    default_key => "platformy",
                    :fruit => ["banana"],
                    :deep => { :platform => "stuff" }
                  }
                }
              ]
            }).public_send(key, "sweet", "plat").must_equal({
              default_key => "platformy",
              :color => "purple",
              :fruit => ["banana"],
              :deep => {
                :common => "junk",
                :platform => "stuff"
              }
            })
          end

          it "suite into common" do
            DataMunger.new({
              key => {
                default_key => "commony",
                :color => "purple",
                :fruit => ["apple", "pear"],
                :deep => { :common => "junk" }
              },
              :suites => [
                {
                  :name => "sweet",
                  key => {
                    default_key => "suitey",
                    :vehicle => "car",
                    :deep => { :suite => "things" }
                  }
                }
              ]
            }).public_send(key, "sweet", "plat").must_equal({
              default_key => "suitey",
              :color => "purple",
              :fruit => ["apple", "pear"],
              :vehicle => "car",
              :deep => {
                :common => "junk",
                :suite => "things"
              }
            })
          end

          it "suite into platform" do
            DataMunger.new({
              :platforms => [
                {
                  :name => "plat",
                  key => {
                    default_key => "platformy",
                    :fruit => ["banana"],
                    :deep => { :platform => "stuff" }
                  }
                }
              ],
              :suites => [
                {
                  :name => "sweet",
                  key => {
                    default_key => "suitey",
                    :vehicle => "car",
                    :deep => { :suite => "things" }
                  }
                }
              ]
            }).public_send(key, "sweet", "plat").must_equal({
              default_key => "suitey",
              :fruit => ["banana"],
              :vehicle => "car",
              :deep => {
                :platform => "stuff",
                :suite => "things"
              }
            })
          end
        end
      end
    end
  end
end

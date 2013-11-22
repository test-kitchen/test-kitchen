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

    describe "#driver" do

      describe "from single source" do

        it "returns common driver config" do
          DataMunger.new({
            :driver => {
              :name => "starship",
              :speed => 42
            }
          }).driver("suite", "platform").must_equal({
            :name => "starship",
            :speed => 42
          })
        end

        it "returns empty hash if no common driver hash is provided" do
          DataMunger.new({}).driver("suite", "platform").must_equal({})
        end

        it "returns platform config containing driver hash" do
          DataMunger.new({
            :platforms => [
              {
                :name => "plat",
                :driver => {
                  :name => "flip",
                  :flop => "yep"
                }
              }
            ]
          }).driver("suite", "plat").must_equal({
            :name => "flip",
            :flop => "yep"
          })
        end

        it "returns empty hash if platform config doesn't have driver hash" do
          DataMunger.new({
            :platforms => [
              { :name => "plat" }
            ]
          }).driver("suite", "plat").must_equal({})
        end

        it "returns suite config containing driver hash" do
          DataMunger.new({
            :suites => [
              {
                :name => "sweet",
                :driver => {
                  :name => "waz",
                  :up => "nope"
                }
              }
            ]
          }).driver("sweet", "platform").must_equal({
            :name => "waz",
            :up => "nope"
          })
        end

        it "returns empty hash if suite config doesn't have driver hash" do
          DataMunger.new({
            :suites => [
              { :name => "sweet" }
            ]
          }).driver("sweet", "platform").must_equal({})
        end
      end

      describe "from multiple sources merging" do

        it "suite into platform into common" do
          DataMunger.new({
            :driver => {
              :name => "commony",
              :color => "purple",
              :fruit => ["apple", "pear"],
              :deep => { :common => "junk" }
            },
            :platforms => [
              {
                :name => "plat",
                :driver => {
                  :name => "platformy",
                  :fruit => ["banana"],
                  :deep => { :platform => "stuff" }
                }
              }
            ],
            :suites => [
              {
                :name => "sweet",
                :driver => {
                  :name => "suitey",
                  :vehicle => "car",
                  :deep => { :suite => "things" }
                }
              }
            ]
          }).driver("sweet", "plat").must_equal({
            :name => "suitey",
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
            :driver => {
              :name => "commony",
              :color => "purple",
              :fruit => ["apple", "pear"],
              :deep => { :common => "junk" }
            },
            :platforms => [
              {
                :name => "plat",
                :driver => {
                  :name => "platformy",
                  :fruit => ["banana"],
                  :deep => { :platform => "stuff" }
                }
              }
            ]
          }).driver("sweet", "plat").must_equal({
            :name => "platformy",
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
            :driver => {
              :name => "commony",
              :color => "purple",
              :fruit => ["apple", "pear"],
              :deep => { :common => "junk" }
            },
            :suites => [
              {
                :name => "sweet",
                :driver => {
                  :name => "suitey",
                  :vehicle => "car",
                  :deep => { :suite => "things" }
                }
              }
            ]
          }).driver("sweet", "plat").must_equal({
            :name => "suitey",
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
                :driver => {
                  :name => "platformy",
                  :fruit => ["banana"],
                  :deep => { :platform => "stuff" }
                }
              }
            ],
            :suites => [
              {
                :name => "sweet",
                :driver => {
                  :name => "suitey",
                  :vehicle => "car",
                  :deep => { :suite => "things" }
                }
              }
            ]
          }).driver("sweet", "plat").must_equal({
            :name => "suitey",
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

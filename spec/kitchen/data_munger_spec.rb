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

        it "returns empty hash if no common driver hash is provided" do
          DataMunger.new({}).driver("suite", "platform").must_equal({})
        end

        it "returns common driver name" do
          DataMunger.new({
            :driver => "starship"
          }).driver("suite", "platform").must_equal({
            :name => "starship"
          })
        end

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

        it "returns empty hash if platform config doesn't have driver hash" do
          DataMunger.new({
            :platforms => [
              { :name => "plat" }
            ]
          }).driver("suite", "plat").must_equal({})
        end

        it "returns platform driver name" do
          DataMunger.new({
            :platforms => [
              {
                :name => "plat",
                :driver => "flip"
              }
            ]
          }).driver("suite", "plat").must_equal({
            :name => "flip"
          })
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

        it "returns empty hash if suite config doesn't have driver hash" do
          DataMunger.new({
            :suites => [
              { :name => "sweet" }
            ]
          }).driver("sweet", "platform").must_equal({})
        end

        it "returns suite driver name" do
          DataMunger.new({
            :suites => [
              {
                :name => "sweet",
                :driver => "waz"
              }
            ]
          }).driver("sweet", "platform").must_equal({
            :name => "waz"
          })
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

    describe "#provisioner" do

      describe "from single source" do

        it "returns empty hash if no common provisioner hash is provided" do
          DataMunger.new({}).provisioner("suite", "platform").must_equal({})
        end

        it "returns common provisioner name" do
          DataMunger.new({
            :provisioner => "starship"
          }).provisioner("suite", "platform").must_equal({
            :name => "starship"
          })
        end

        it "returns common provisioner config" do
          DataMunger.new({
            :provisioner => {
              :name => "starship",
              :speed => 42
            }
          }).provisioner("suite", "platform").must_equal({
            :name => "starship",
            :speed => 42
          })
        end

        it "returns empty hash if platform config doesn't have provisioner hash" do
          DataMunger.new({
            :platforms => [
              { :name => "plat" }
            ]
          }).provisioner("suite", "plat").must_equal({})
        end

        it "returns platform provisioner name" do
          DataMunger.new({
            :platforms => [
              {
                :name => "plat",
                :provisioner => "flip"
              }
            ]
          }).provisioner("suite", "plat").must_equal({
            :name => "flip"
          })
        end

        it "returns platform config containing provisioner hash" do
          DataMunger.new({
            :platforms => [
              {
                :name => "plat",
                :provisioner => {
                  :name => "flip",
                  :flop => "yep"
                }
              }
            ]
          }).provisioner("suite", "plat").must_equal({
            :name => "flip",
            :flop => "yep"
          })
        end

        it "returns empty hash if suite config doesn't have provisioner hash" do
          DataMunger.new({
            :suites => [
              { :name => "sweet" }
            ]
          }).provisioner("sweet", "platform").must_equal({})
        end

        it "returns suite provisioner name" do
          DataMunger.new({
            :suites => [
              {
                :name => "sweet",
                :provisioner => "waz"
              }
            ]
          }).provisioner("sweet", "platform").must_equal({
            :name => "waz"
          })
        end

        it "returns suite config containing provisioner hash" do
          DataMunger.new({
            :suites => [
              {
                :name => "sweet",
                :provisioner => {
                  :name => "waz",
                  :up => "nope"
                }
              }
            ]
          }).provisioner("sweet", "platform").must_equal({
            :name => "waz",
            :up => "nope"
          })
        end
      end

      describe "from multiple sources merging" do

        it "suite into platform into common" do
          DataMunger.new({
            :provisioner => {
              :name => "commony",
              :color => "purple",
              :fruit => ["apple", "pear"],
              :deep => { :common => "junk" }
            },
            :platforms => [
              {
                :name => "plat",
                :provisioner => {
                  :name => "platformy",
                  :fruit => ["banana"],
                  :deep => { :platform => "stuff" }
                }
              }
            ],
            :suites => [
              {
                :name => "sweet",
                :provisioner => {
                  :name => "suitey",
                  :vehicle => "car",
                  :deep => { :suite => "things" }
                }
              }
            ]
          }).provisioner("sweet", "plat").must_equal({
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
            :provisioner => {
              :name => "commony",
              :color => "purple",
              :fruit => ["apple", "pear"],
              :deep => { :common => "junk" }
            },
            :platforms => [
              {
                :name => "plat",
                :provisioner => {
                  :name => "platformy",
                  :fruit => ["banana"],
                  :deep => { :platform => "stuff" }
                }
              }
            ]
          }).provisioner("sweet", "plat").must_equal({
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
            :provisioner => {
              :name => "commony",
              :color => "purple",
              :fruit => ["apple", "pear"],
              :deep => { :common => "junk" }
            },
            :suites => [
              {
                :name => "sweet",
                :provisioner => {
                  :name => "suitey",
                  :vehicle => "car",
                  :deep => { :suite => "things" }
                }
              }
            ]
          }).provisioner("sweet", "plat").must_equal({
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
                :provisioner => {
                  :name => "platformy",
                  :fruit => ["banana"],
                  :deep => { :platform => "stuff" }
                }
              }
            ],
            :suites => [
              {
                :name => "sweet",
                :provisioner => {
                  :name => "suitey",
                  :vehicle => "car",
                  :deep => { :suite => "things" }
                }
              }
            ]
          }).provisioner("sweet", "plat").must_equal({
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

    describe "#busser" do

      describe "from single source" do

        it "returns empty hash if no common busser hash is provided" do
          DataMunger.new({}).busser("suite", "platform").must_equal({})
        end

        it "returns common busser version" do
          DataMunger.new({
            :busser => "starship"
          }).busser("suite", "platform").must_equal({
            :version => "starship"
          })
        end

        it "returns common busser config" do
          DataMunger.new({
            :busser => {
              :version => "starship",
              :speed => 42
            }
          }).busser("suite", "platform").must_equal({
            :version => "starship",
            :speed => 42
          })
        end

        it "returns empty hash if platform config doesn't have busser hash" do
          DataMunger.new({
            :platforms => [
              { :version => "plat" }
            ]
          }).busser("suite", "plat").must_equal({})
        end

        it "returns platform busser version" do
          DataMunger.new({
            :platforms => [
              {
                :version => "plat",
                :busser => "flip"
              }
            ]
          }).busser("suite", "plat").must_equal({
            :version => "flip"
          })
        end

        it "returns platform config containing busser hash" do
          DataMunger.new({
            :platforms => [
              {
                :version => "plat",
                :busser => {
                  :version => "flip",
                  :flop => "yep"
                }
              }
            ]
          }).busser("suite", "plat").must_equal({
            :version => "flip",
            :flop => "yep"
          })
        end

        it "returns empty hash if suite config doesn't have busser hash" do
          DataMunger.new({
            :suites => [
              { :version => "sweet" }
            ]
          }).busser("sweet", "platform").must_equal({})
        end

        it "returns suite busser version" do
          DataMunger.new({
            :suites => [
              {
                :version => "sweet",
                :busser => "waz"
              }
            ]
          }).busser("sweet", "platform").must_equal({
            :version => "waz"
          })
        end

        it "returns suite config containing busser hash" do
          DataMunger.new({
            :suites => [
              {
                :version => "sweet",
                :busser => {
                  :version => "waz",
                  :up => "nope"
                }
              }
            ]
          }).busser("sweet", "platform").must_equal({
            :version => "waz",
            :up => "nope"
          })
        end
      end

      describe "from multiple sources merging" do

        it "suite into platform into common" do
          DataMunger.new({
            :busser => {
              :version => "commony",
              :color => "purple",
              :fruit => ["apple", "pear"],
              :deep => { :common => "junk" }
            },
            :platforms => [
              {
                :version => "plat",
                :busser => {
                  :version => "platformy",
                  :fruit => ["banana"],
                  :deep => { :platform => "stuff" }
                }
              }
            ],
            :suites => [
              {
                :version => "sweet",
                :busser => {
                  :version => "suitey",
                  :vehicle => "car",
                  :deep => { :suite => "things" }
                }
              }
            ]
          }).busser("sweet", "plat").must_equal({
            :version => "suitey",
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
            :busser => {
              :version => "commony",
              :color => "purple",
              :fruit => ["apple", "pear"],
              :deep => { :common => "junk" }
            },
            :platforms => [
              {
                :version => "plat",
                :busser => {
                  :version => "platformy",
                  :fruit => ["banana"],
                  :deep => { :platform => "stuff" }
                }
              }
            ]
          }).busser("sweet", "plat").must_equal({
            :version => "platformy",
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
            :busser => {
              :version => "commony",
              :color => "purple",
              :fruit => ["apple", "pear"],
              :deep => { :common => "junk" }
            },
            :suites => [
              {
                :version => "sweet",
                :busser => {
                  :version => "suitey",
                  :vehicle => "car",
                  :deep => { :suite => "things" }
                }
              }
            ]
          }).busser("sweet", "plat").must_equal({
            :version => "suitey",
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
                :version => "plat",
                :busser => {
                  :version => "platformy",
                  :fruit => ["banana"],
                  :deep => { :platform => "stuff" }
                }
              }
            ],
            :suites => [
              {
                :version => "sweet",
                :busser => {
                  :version => "suitey",
                  :vehicle => "car",
                  :deep => { :suite => "things" }
                }
              }
            ]
          }).busser("sweet", "plat").must_equal({
            :version => "suitey",
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

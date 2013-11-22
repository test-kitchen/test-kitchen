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
            }).public_send("#{key}_data_for", "suite", "platform").must_equal({
            })
          end

          it "returns common #{key} name" do
            DataMunger.new({
              key => "starship"
            }).public_send("#{key}_data_for", "suite", "platform").must_equal({
              default_key => "starship"
            })
          end

          it "returns common #{key} config" do
            DataMunger.new({
              key => {
                default_key => "starship",
                :speed => 42
              }
            }).public_send("#{key}_data_for", "suite", "platform").must_equal({
              default_key => "starship",
              :speed => 42
            })
          end

          it "returns empty hash if platform config doesn't have #{key} hash" do
            DataMunger.new({
              :platforms => [
                { :name => "plat" }
              ]
            }).public_send("#{key}_data_for", "suite", "plat").must_equal({})
          end

          it "returns platform #{key} name" do
            DataMunger.new({
              :platforms => [
                {
                  :name => "plat",
                  key => "flip"
                }
              ]
            }).public_send("#{key}_data_for", "suite", "plat").must_equal({
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
            }).public_send("#{key}_data_for", "suite", "plat").must_equal({
              default_key => "flip",
              :flop => "yep"
            })
          end

          it "returns empty hash if suite config doesn't have #{key} hash" do
            DataMunger.new({
              :suites => [
                { :name => "sweet" }
              ]
            }).public_send("#{key}_data_for", "sweet", "platform").must_equal({
            })
          end

          it "returns suite #{key} name" do
            DataMunger.new({
              :suites => [
                {
                  :name => "sweet",
                  key => "waz"
                }
              ]
            }).public_send("#{key}_data_for", "sweet", "platform").must_equal({
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
            }).public_send("#{key}_data_for", "sweet", "platform").must_equal({
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
            }).public_send("#{key}_data_for", "sweet", "plat").must_equal({
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
            }).public_send("#{key}_data_for", "sweet", "plat").must_equal({
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
            }).public_send("#{key}_data_for", "sweet", "plat").must_equal({
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
            }).public_send("#{key}_data_for", "sweet", "plat").must_equal({
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

    describe "legacy driver_config and driver_plugin" do

      describe "from a single source" do

        it "returns common driver name" do
          DataMunger.new({
            :driver_plugin => "starship"
          }).driver_data_for("suite", "platform").must_equal({
            :name => "starship"
          })
        end

        it "merges driver into driver_plugin if driver exists" do
          DataMunger.new({
            :driver_plugin => "starship",
            :driver => "zappa"
          }).driver_data_for("suite", "platform").must_equal({
            :name => "zappa"
          })
        end

        it "returns common driver config" do
          DataMunger.new({
            :driver_plugin => "starship",
            :driver_config => {
              :speed => 42
            }
          }).driver_data_for("suite", "platform").must_equal({
            :name => "starship",
            :speed => 42
          })
        end

        it "merges driver into driver_config if driver with name exists" do
          DataMunger.new({
            :driver_config => {
              :eh => "yep"
            },
            :driver => "zappa"
          }).driver_data_for("suite", "platform").must_equal({
            :name => "zappa",
            :eh => "yep"
          })
        end

        it "merges driver into driver_config if driver exists" do
          DataMunger.new({
            :driver_plugin => "imold",
            :driver_config => {
              :eh => "yep",
              :color => "pink"
            },
            :driver => {
              :name => "zappa",
              :color => "black"
            }
          }).driver_data_for("suite", "platform").must_equal({
            :name => "zappa",
            :eh => "yep",
            :color => "black"
          })
        end

        it "returns platform driver name" do
          DataMunger.new({
            :platforms => [
              {
                :name => "plat",
                :driver_plugin => "flip"
              }
            ]
          }).driver_data_for("suite", "plat").must_equal({
            :name => "flip"
          })
        end

        it "returns platform config containing driver hash" do
          DataMunger.new({
            :platforms => [
              {
                :name => "plat",
                :driver_plugin => "flip",
                :driver_config => {
                  :flop => "yep"
                }
              }
            ]
          }).driver_data_for("suite", "plat").must_equal({
            :name => "flip",
            :flop => "yep"
          })
        end

        it "returns suite driver name" do
          DataMunger.new({
            :suites => [
              {
                :name => "sweet",
                :driver_plugin => "waz"
              }
            ]
          }).driver_data_for("sweet", "platform").must_equal({
            :name => "waz"
          })
        end

        it "returns suite config containing driver hash" do
          DataMunger.new({
            :suites => [
              {
                :name => "sweet",
                :driver_plugin => "waz",
                :driver_config => {
                  :up => "nope"
                }
              }
            ]
          }).driver_data_for("sweet", "platform").must_equal({
            :name => "waz",
            :up => "nope"
          })
        end
      end

      describe "from multiple sources" do

        it "suite into platform into common" do
          DataMunger.new({
            :driver_plugin => "commony",
            :driver_config => {
              :color => "purple",
              :fruit => ["apple", "pear"],
              :deep => { :common => "junk" }
            },
            :platforms => [
              {
                :name => "plat",
                :driver_plugin => "platformy",
                :driver_config => {
                  :fruit => ["banana"],
                  :deep => { :platform => "stuff" }
                }
              }
            ],
            :suites => [
              {
                :name => "sweet",
                :driver_plugin => "suitey",
                :driver_config => {
                  :vehicle => "car",
                  :deep => { :suite => "things" }
                }
              }
            ]
          }).driver_data_for("sweet", "plat").must_equal({
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
            :driver_plugin => "commony",
            :driver_config => {
              :color => "purple",
              :fruit => ["apple", "pear"],
              :deep => { :common => "junk" }
            },
            :platforms => [
              {
                :name => "plat",
                :driver_plugin => "platformy",
                :driver_config => {
                  :fruit => ["banana"],
                  :deep => { :platform => "stuff" }
                }
              }
            ]
          }).driver_data_for("sweet", "plat").must_equal({
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
            :driver_plugin => "commony",
            :driver_config => {
              :color => "purple",
              :fruit => ["apple", "pear"],
              :deep => { :common => "junk" }
            },
            :suites => [
              {
                :name => "sweet",
                :driver_plugin => "suitey",
                :driver_config => {
                  :vehicle => "car",
                  :deep => { :suite => "things" }
                }
              }
            ]
          }).driver_data_for("sweet", "plat").must_equal({
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
                :driver_plugin => "platformy",
                :driver_config => {
                  :fruit => ["banana"],
                  :deep => { :platform => "stuff" }
                }
              }
            ],
            :suites => [
              {
                :name => "sweet",
                :driver_plugin => "suitey",
                :driver_config => {
                  :vehicle => "car",
                  :deep => { :suite => "things" }
                }
              }
            ]
          }).driver_data_for("sweet", "plat").must_equal({
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

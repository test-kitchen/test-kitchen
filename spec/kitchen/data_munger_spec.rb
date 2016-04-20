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

require "kitchen/data_munger"

module Kitchen # rubocop:disable Metrics/ModuleLength

  describe DataMunger do

    describe "#platform_data" do

      it "returns an array of platform data" do
        DataMunger.new(
          :platforms => [
            {
              :name => "one",
              :stuff => "junk"
            },
            {
              :name => "two",
              :misc => "things"
            }
          ]
        ).platform_data.must_equal([
          {
            :name => "one",
            :stuff => "junk"
          },
          {
            :name => "two",
            :misc => "things"
          }
        ])
      end

      it "returns an empty array if platforms is not defined" do
        DataMunger.new({}).platform_data.must_equal([])
      end
    end

    describe "#suite_data" do

      it "returns an array of suite data" do
        DataMunger.new(
          :suites => [
            {
              :name => "one",
              :stuff => "junk"
            },
            {
              :name => "two",
              :misc => "things"
            }
          ]
        ).suite_data.must_equal([
          {
            :name => "one",
            :stuff => "junk"
          },
          {
            :name => "two",
            :misc => "things"
          }
        ])
      end

      it "returns an empty array if suites is not defined" do
        DataMunger.new({}).suite_data.must_equal([])
      end
    end

    DATA_KEYS = {
      :driver => :name,
      :provisioner => :name,
      :transport => :name,
      :verifier => :name
    }

    DATA_KEYS.each_pair do |key, default_key|

      describe "##{key}" do

        describe "from single source" do

          it "returns empty hash if no common #{key} hash is provided" do
            DataMunger.new(
              {},
              {}
            ).public_send("#{key}_data_for", "suite", "platform").must_equal({})
          end

          it "drops common #{key} if hash is nil" do
            DataMunger.new(
              {
                key => nil
              },
              {}
            ).public_send("#{key}_data_for", "suite", "plat").must_equal({})
          end

          it "returns kitchen config #{key} name" do
            DataMunger.new(
              {},
              {
                :defaults => {
                  key => "thenoseknows"
                }
              }
            ).public_send("#{key}_data_for", "suite", "platform").must_equal(
              default_key => "thenoseknows"
            )
          end

          it "returns kitchen config #{key} name from callable" do
            DataMunger.new(
              {},
              {
                :defaults => {
                  key => ->(suite, platform) { "#{suite}++#{platform}" }
                }
              }
            ).public_send("#{key}_data_for", "suite", "platform").must_equal(
              default_key => "suite++platform"
            )
          end

          it "returns common #{key} name" do
            DataMunger.new(
              {
                key => "starship"
              },
              {}
            ).public_send("#{key}_data_for", "suite", "platform").must_equal(
              default_key => "starship"
            )
          end

          it "returns common #{key} config" do
            DataMunger.new(
              {
                key => {
                  default_key => "starship",
                  :speed => 42
                }
              },
              {}
            ).public_send("#{key}_data_for", "suite", "platform").must_equal(
              default_key => "starship",
              :speed => 42
            )
          end

          it "returns empty hash if platform config doesn't have #{key} hash" do
            DataMunger.new(
              {
                :platforms => [
                  { :name => "plat" }
                ]
              },
              {}
            ).public_send("#{key}_data_for", "suite", "plat").must_equal({})
          end

          it "drops platform #{key} if hash is nil" do
            DataMunger.new(
              {
                :platforms => [
                  {
                    :name => "plat",
                    key => nil
                  }
                ]
              },
              {}
            ).public_send("#{key}_data_for", "suite", "plat").must_equal({})
          end

          it "returns platform #{key} name" do
            DataMunger.new(
              {
                :platforms => [
                  {
                    :name => "plat",
                    key => "flip"
                  }
                ]
              },
              {}
            ).public_send("#{key}_data_for", "suite", "plat").must_equal(
              default_key => "flip"
            )
          end

          it "returns platform config containing #{key} hash" do
            DataMunger.new(
              {
                :platforms => [
                  {
                    :name => "plat",
                    key => {
                      default_key => "flip",
                      :flop => "yep"
                    }
                  }
                ]
              },
              {}
            ).public_send("#{key}_data_for", "suite", "plat").must_equal(
              default_key => "flip",
              :flop => "yep"
            )
          end

          it "returns empty hash if suite config doesn't have #{key} hash" do
            DataMunger.new(
              {
                :suites => [
                  { :name => "sweet" }
                ]
              },
              {}
            ).public_send("#{key}_data_for", "sweet", "platform").must_equal({})
          end

          it "drops suite #{key} hash is nil" do
            DataMunger.new(
              {
                :suites => [
                  {
                    :name => "suite",
                    key => nil
                  }
                ]
              },
              {}
            ).public_send("#{key}_data_for", "suite", "plat").must_equal({})
          end

          it "returns suite #{key} name" do
            DataMunger.new(
              {
                :suites => [
                  {
                    :name => "sweet",
                    key => "waz"
                  }
                ]
              },
              {}
            ).public_send("#{key}_data_for", "sweet", "platform").must_equal(
              default_key => "waz"
            )
          end

          it "returns suite config containing #{key} hash" do
            DataMunger.new(
              {
                :suites => [
                  {
                    :name => "sweet",
                    key => {
                      default_key => "waz",
                      :up => "nope"
                    }
                  }
                ]
              },
              {}
            ).public_send("#{key}_data_for", "sweet", "platform").must_equal(
              default_key => "waz",
              :up => "nope"
            )
          end
        end

        describe "from multiple sources merging" do

          it "suite into platform into common" do
            DataMunger.new(
              {
                key => {
                  default_key => "commony",
                  :color => "purple",
                  :fruit => %w[apple pear],
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
              },
              {}
            ).public_send("#{key}_data_for", "sweet", "plat").must_equal(
              default_key => "suitey",
              :color => "purple",
              :fruit => ["banana"],
              :vehicle => "car",
              :deep => {
                :common => "junk",
                :platform => "stuff",
                :suite => "things"
              }
            )
          end

          it "platform into common" do
            DataMunger.new(
              {
                key => {
                  default_key => "commony",
                  :color => "purple",
                  :fruit => %w[apple pear],
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
              },
              {}
            ).public_send("#{key}_data_for", "sweet", "plat").must_equal(
              default_key => "platformy",
              :color => "purple",
              :fruit => ["banana"],
              :deep => {
                :common => "junk",
                :platform => "stuff"
              }
            )
          end

          it "suite into common" do
            DataMunger.new(
              {
                key => {
                  default_key => "commony",
                  :color => "purple",
                  :fruit => %w[apple pear],
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
              },
              {}
            ).public_send("#{key}_data_for", "sweet", "plat").must_equal(
              default_key => "suitey",
              :color => "purple",
              :fruit => %w[apple pear],
              :vehicle => "car",
              :deep => {
                :common => "junk",
                :suite => "things"
              }
            )
          end

          it "suite into platform" do
            DataMunger.new(
              {
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
              },
              {}
            ).public_send("#{key}_data_for", "sweet", "plat").must_equal(
              default_key => "suitey",
              :fruit => ["banana"],
              :vehicle => "car",
              :deep => {
                :platform => "stuff",
                :suite => "things"
              }
            )
          end
        end
      end
    end

    describe "primary Chef data" do

      describe "in a suite" do

        it "moves attributes into provisioner" do
          DataMunger.new(
            {
              :provisioner => "chefy",
              :suites => [
                {
                  :name => "sweet",
                  :attributes => { :one => "two" }
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :attributes => { :one => "two" }
          )
        end

        it "moves run_list into provisioner" do
          DataMunger.new(
            {
              :provisioner => "chefy",
              :suites => [
                {
                  :name => "sweet",
                  :run_list => %w[one two]
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :run_list => %w[one two]
          )
        end

        it "moves named_run_list into provisioner" do
          DataMunger.new(
            {
              :provisioner => "chefy",
              :suites => [
                {
                  :name => "sweet",
                  :named_run_list => "other_run_list"
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :named_run_list => "other_run_list"
          )
        end
        it "maintains run_list in provisioner" do
          DataMunger.new(
            {
              :provisioner => "chefy",
              :suites => [
                {
                  :name => "sweet",
                  :provisioner => {
                    :run_list => %w[one two]
                  }
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :run_list => %w[one two]
          )
        end

        it "merge provisioner into attributes if provisioner exists" do
          DataMunger.new(
            {
              :suites => [
                {
                  :name => "sweet",
                  :attributes => { :one => "two" },
                  :provisioner => "chefy"
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :attributes => { :one => "two" }
          )
        end

        it "merge provisioner into run_list if provisioner exists" do
          DataMunger.new(
            {
              :suites => [
                {
                  :name => "sweet",
                  :run_list => %w[one two],
                  :provisioner => "chefy"
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :run_list => %w[one two]
          )
        end

        it "merge provisioner into named_run_list if provisioner exists" do
          DataMunger.new(
            {
              :suites => [
                {
                  :name => "sweet",
                  :named_run_list => "other_run_list",
                  :provisioner => "chefy"
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :named_run_list => "other_run_list"
          )
        end
        it "drops nil run_list" do
          DataMunger.new(
            {
              :suites => [
                {
                  :name => "sweet",
                  :run_list => nil,
                  :provisioner => "chefy"
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy"
          )
        end

        it "drops nil attributes" do
          DataMunger.new(
            {
              :suites => [
                {
                  :name => "sweet",
                  :attributes => nil,
                  :provisioner => "chefy"
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy"
          )
        end
      end

      describe "in a platform" do

        it "moves attributes into provisioner" do
          DataMunger.new(
            {
              :provisioner => "chefy",
              :platforms => [
                {
                  :name => "plat",
                  :attributes => { :one => "two" }
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :attributes => { :one => "two" }
          )
        end

        it "moves run_list into provisioner" do
          DataMunger.new(
            {
              :provisioner => "chefy",
              :platforms => [
                {
                  :name => "plat",
                  :run_list => %w[one two]
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :run_list => %w[one two]
          )
        end

        it "moves named_run_list into provisioner" do
          DataMunger.new(
            {
              :provisioner => "chefy",
              :platforms => [
                {
                  :name => "plat",
                  :named_run_list => "other_run_list"
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :named_run_list => "other_run_list"
          )
        end
        it "maintains run_list in provisioner" do
          DataMunger.new(
            {
              :provisioner => "chefy",
              :platforms => [
                {
                  :name => "plat",
                  :provisioner => {
                    :run_list => %w[one two]
                  }
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :run_list => %w[one two]
          )
        end

        it "merge provisioner into attributes if provisioner exists" do
          DataMunger.new(
            {
              :platforms => [
                {
                  :name => "plat",
                  :attributes => { :one => "two" },
                  :provisioner => "chefy"
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :attributes => { :one => "two" }
          )
        end

        it "merge provisioner into run_list if provisioner exists" do
          DataMunger.new(
            {
              :platforms => [
                {
                  :name => "plat",
                  :run_list => %w[one two],
                  :provisioner => "chefy"
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :run_list => %w[one two]
          )
        end

        it "merge provisioner into named_run_list if provisioner exists" do
          DataMunger.new(
            {
              :platforms => [
                {
                  :name => "plat",
                  :named_run_list => "other_run_list",
                  :provisioner => "chefy"
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :named_run_list => "other_run_list"
          )
        end
        it "drops nil run_list" do
          DataMunger.new(
            {
              :platforms => [
                {
                  :name => "plat",
                  :run_list => nil,
                  :provisioner => "chefy"
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy"
          )
        end

        it "drops nil attributes" do
          DataMunger.new(
            {
              :platforms => [
                {
                  :name => "plat",
                  :attributes => nil,
                  :provisioner => "chefy"
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy"
          )
        end
      end

      describe "in a suite and platform" do

        it "merges suite attributes into platform attributes" do
          DataMunger.new(
            {
              :provisioner => "chefy",
              :platforms => [
                {
                  :name => "plat",
                  :attributes => {
                    :color => "blue",
                    :deep => { :platform => "much" }
                  }
                }
              ],
              :suites => [
                {
                  :name => "sweet",
                  :attributes => {
                    :color => "pink",
                    :deep => { :suite => "wow" }
                  }
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :attributes => {
              :color => "pink",
              :deep => {
                :suite => "wow",
                :platform => "much"
              }
            }
          )
        end

        it "concats suite run_list to platform run_list" do
          DataMunger.new(
            {
              :provisioner => "chefy",
              :platforms => [
                {
                  :name => "plat",
                  :run_list => %w[one two]
                }
              ],
              :suites => [
                {
                  :name => "sweet",
                  :run_list => %w[three four]
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :run_list => %w[one two three four]
          )
        end

        it "concats suite run_list in provisioner to platform run_list" do
          DataMunger.new(
            {
              :provisioner => "chefy",
              :platforms => [
                {
                  :name => "plat",
                  :run_list => %w[one two]
                }
              ],
              :suites => [
                {
                  :name => "sweet",
                  :provisioner => {
                    :run_list => %w[three four]
                  }
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :run_list => %w[one two three four]
          )
        end

        it "concats suite run_list to platform run_list in provisioner" do
          DataMunger.new(
            {
              :provisioner => "chefy",
              :platforms => [
                {
                  :name => "plat",
                  :provisioner => {
                    :run_list => %w[one two]
                  }
                }
              ],
              :suites => [
                {
                  :name => "sweet",
                  :run_list => %w[three four]
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :run_list => %w[one two three four]
          )
        end

        it "concats to nil run_lists into an empty Array" do
          DataMunger.new(
            {
              :provisioner => "chefy",
              :platforms => [
                {
                  :name => "plat",
                  :provisioner => {
                    :run_list => nil
                  }
                }
              ],
              :suites => [
                {
                  :name => "sweet",
                  :run_list => nil
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            :run_list => []
          )
        end

        it "does not corrupt run_list data for multiple suite/platform pairs" do
          munger = DataMunger.new(
            {
              :provisioner => "chefy",
              :platforms => [
                {
                  :name => "p1"
                },
                {
                  :name => "p2",
                  :run_list => %w[one two]
                }
              ],
              :suites => [
                {
                  :name => "s1",
                  :run_list => %w[alpha beta]
                },
                {
                  :name => "s2",
                  :provisioner => {
                    :run_list => %w[three four]
                  }
                }
              ]
            },
            {}
          )

          # call munger for other data to cause any necessary internal
          # data mutation
          munger.provisioner_data_for("s1", "p1")
          munger.provisioner_data_for("s1", "p2")
          munger.provisioner_data_for("s2", "p1")

          munger.provisioner_data_for("s2", "p2").must_equal(
            :name => "chefy",
            :run_list => %w[one two three four]
          )
        end
      end
    end

    describe "kitchen config" do

      [:kitchen_root, :test_base_path].each do |key|

        describe "for #{key}" do

          describe "for #driver_data_for" do

            it "is returned when provided" do
              DataMunger.new(
                {
                  :driver => "chefy",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {
                  key => "datvalue"
                }
              ).driver_data_for("sweet", "plat").must_equal(
                :name => "chefy",
                key => "datvalue"
              )
            end

            it "is returned when provided in user data" do
              DataMunger.new(
                {
                  :kitchen => {
                    key => "datvalue"
                  },
                  :driver => "chefy",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {}
              ).driver_data_for("sweet", "plat").must_equal(
                :name => "chefy",
                key => "datvalue"
              )
            end

            it "user data value beats provided value" do
              DataMunger.new(
                {
                  :kitchen => {
                    key => "datvalue"
                  },
                  :driver => "chefy",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {
                  key => "ilose"
                }
              ).driver_data_for("sweet", "plat").must_equal(
                :name => "chefy",
                key => "datvalue"
              )
            end

            it "rejects any value in driver data" do
              DataMunger.new(
                {
                  :driver => {
                    :name => "chefy",
                    key => "imevil"
                  },
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {}
              ).driver_data_for("sweet", "plat").must_equal(
                :name => "chefy"
              )
            end
          end

          describe "for #provisioner_data_for" do

            it "is returned when provided" do
              DataMunger.new(
                {
                  :provisioner => "chefy",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {
                  key => "datvalue"
                }
              ).provisioner_data_for("sweet", "plat").must_equal(
                :name => "chefy",
                key => "datvalue"
              )
            end

            it "is returned when provided in user data" do
              DataMunger.new(
                {
                  :kitchen => {
                    key => "datvalue"
                  },
                  :provisioner => "chefy",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {}
              ).provisioner_data_for("sweet", "plat").must_equal(
                :name => "chefy",
                key => "datvalue"
              )
            end

            it "user data value beats provided value" do
              DataMunger.new(
                {
                  :kitchen => {
                    key => "datvalue"
                  },
                  :provisioner => "chefy",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {
                  key => "ilose"
                }
              ).provisioner_data_for("sweet", "plat").must_equal(
                :name => "chefy",
                key => "datvalue"
              )
            end

            it "rejects any value in provisioner data" do
              DataMunger.new(
                {
                  :provisioner => {
                    :name => "chefy",
                    key => "imevil"
                  },
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {}
              ).provisioner_data_for("sweet", "plat").must_equal(
                :name => "chefy"
              )
            end
          end

          describe "for #verifier_data_for" do

            it "is returned when provided" do
              DataMunger.new(
                {
                  :verifier => "chefy",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {
                  key => "datvalue"
                }
              ).verifier_data_for("sweet", "plat").must_equal(
                :name => "chefy",
                key => "datvalue"
              )
            end

            it "is returned when provided in user data" do
              DataMunger.new(
                {
                  :kitchen => {
                    key => "datvalue"
                  },
                  :verifier => "chefy",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {}
              ).verifier_data_for("sweet", "plat").must_equal(
                :name => "chefy",
                key => "datvalue"
              )
            end

            it "user data value beats provided value" do
              DataMunger.new(
                {
                  :kitchen => {
                    key => "datvalue"
                  },
                  :verifier => "chefy",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {
                  key => "ilose"
                }
              ).verifier_data_for("sweet", "plat").must_equal(
                :name => "chefy",
                key => "datvalue"
              )
            end

            it "rejects any value in verifier data" do
              DataMunger.new(
                {
                  :verifier => {
                    :version => "chefy",
                    key => "imevil"
                  },
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {}
              ).verifier_data_for("sweet", "plat").must_equal(
                :version => "chefy"
              )
            end
          end

          describe "for #transport_data_for" do

            it "is returned when provided" do
              DataMunger.new(
                {
                  :transport => "pipes",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {
                  key => "datvalue"
                }
              ).transport_data_for("sweet", "plat").must_equal(
                :name => "pipes",
                key => "datvalue"
              )
            end

            it "is returned when provided in user data" do
              DataMunger.new(
                {
                  :kitchen => {
                    key => "datvalue"
                  },
                  :transport => "pipes",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {}
              ).transport_data_for("sweet", "plat").must_equal(
                :name => "pipes",
                key => "datvalue"
              )
            end

            it "user data value beats provided value" do
              DataMunger.new(
                {
                  :kitchen => {
                    key => "datvalue"
                  },
                  :transport => "pipes",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {
                  key => "ilose"
                }
              ).transport_data_for("sweet", "plat").must_equal(
                :name => "pipes",
                key => "datvalue"
              )
            end

            it "rejects any value in transport data" do
              DataMunger.new(
                {
                  :transport => {
                    :name => "pipes",
                    key => "imevil"
                  },
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {}
              ).transport_data_for("sweet", "plat").must_equal(
                :name => "pipes"
              )
            end
          end
        end
      end

      [:log_level].each do |key|

        describe "for #{key}" do

          describe "for #driver_data_for" do

            it "is returned when provided" do
              DataMunger.new(
                {
                  :driver => "chefy",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {
                  key => "datvalue"
                }
              ).driver_data_for("sweet", "plat").must_equal(
                :name => "chefy",
                key => "datvalue"
              )
            end

            it "is returned when provided in user data" do
              DataMunger.new(
                {
                  :kitchen => {
                    key => "datvalue"
                  },
                  :driver => "chefy",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {}
              ).driver_data_for("sweet", "plat").must_equal(
                :name => "chefy",
                key => "datvalue"
              )
            end

            it "user data value beats provided value" do
              DataMunger.new(
                {
                  :kitchen => {
                    key => "datvalue"
                  },
                  :driver => "chefy",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {
                  key => "ilose"
                }
              ).driver_data_for("sweet", "plat").must_equal(
                :name => "chefy",
                key => "datvalue"
              )
            end

            it "rejects any value in driver data" do
              DataMunger.new(
                {
                  :driver => {
                    :name => "chefy",
                    key => "imevil"
                  },
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {}
              ).driver_data_for("sweet", "plat").must_equal(
                :name => "chefy"
              )
            end
          end

          describe "for #provisioner_data_for" do

            it "uses value in provisioner data" do
              DataMunger.new(
                {
                  :provisioner => {
                    :name => "chefy",
                    key => "datvalue"
                  },
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {}
              ).provisioner_data_for("sweet", "plat").must_equal(
                :name => "chefy",
                key => "datvalue"
              )
            end

            it "rejects any value in user data" do
              DataMunger.new(
                {
                  :kitchen => {
                    key => "imevil"
                  },
                  :provisioner => "chefy",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {}
              ).provisioner_data_for("sweet", "plat").must_equal(
                :name => "chefy"
              )
            end
          end

          describe "for #verifier_data_for" do

            it "is returned when provided" do
              DataMunger.new(
                {
                  :verifier => "chefy",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {
                  key => "datvalue"
                }
              ).verifier_data_for("sweet", "plat").must_equal(
                :name => "chefy",
                key => "datvalue"
              )
            end

            it "is returned when provided in user data" do
              DataMunger.new(
                {
                  :kitchen => {
                    key => "datvalue"
                  },
                  :verifier => "chefy",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {}
              ).verifier_data_for("sweet", "plat").must_equal(
                :name => "chefy",
                key => "datvalue"
              )
            end

            it "user data value beats provided value" do
              DataMunger.new(
                {
                  :kitchen => {
                    key => "datvalue"
                  },
                  :verifier => "chefy",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {
                  key => "ilose"
                }
              ).verifier_data_for("sweet", "plat").must_equal(
                :name => "chefy",
                key => "datvalue"
              )
            end

            it "rejects any value in verifier data" do
              DataMunger.new(
                {
                  :verifier => {
                    :version => "chefy",
                    key => "imevil"
                  },
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {}
              ).verifier_data_for("sweet", "plat").must_equal(
                :version => "chefy"
              )
            end
          end

          describe "for #transport_data_for" do

            it "is returned when provided" do
              DataMunger.new(
                {
                  :transport => "pipes",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {
                  key => "datvalue"
                }
              ).transport_data_for("sweet", "plat").must_equal(
                :name => "pipes",
                key => "datvalue"
              )
            end

            it "is returned when provided in user data" do
              DataMunger.new(
                {
                  :kitchen => {
                    key => "datvalue"
                  },
                  :transport => "pipes",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {}
              ).transport_data_for("sweet", "plat").must_equal(
                :name => "pipes",
                key => "datvalue"
              )
            end

            it "user data value beats provided value" do
              DataMunger.new(
                {
                  :kitchen => {
                    key => "datvalue"
                  },
                  :transport => "pipes",
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {
                  key => "ilose"
                }
              ).transport_data_for("sweet", "plat").must_equal(
                :name => "pipes",
                key => "datvalue"
              )
            end

            it "rejects any value in transport data" do
              DataMunger.new(
                {
                  :transport => {
                    :name => "pipes",
                    key => "imevil"
                  },
                  :platforms => [
                    { :name => "plat" }
                  ],
                  :suites => [
                    { :name => "sweet" }
                  ]
                },
                {}
              ).transport_data_for("sweet", "plat").must_equal(
                :name => "pipes"
              )
            end
          end
        end
      end
    end

    describe "legacy driver_config and driver_plugin" do

      describe "from a single source" do

        it "returns common driver name" do
          DataMunger.new(
            {
              :driver_plugin => "starship"
            },
            {}
          ).driver_data_for("suite", "platform").must_equal(
            :name => "starship"
          )
        end

        it "merges driver into driver_plugin if driver exists" do
          DataMunger.new(
            {
              :driver_plugin => "starship",
              :driver => "zappa"
            },
            {}
          ).driver_data_for("suite", "platform").must_equal(
            :name => "zappa"
          )
        end

        it "returns common driver config" do
          DataMunger.new(
            {
              :driver_plugin => "starship",
              :driver_config => {
                :speed => 42
              }
            },
            {}
          ).driver_data_for("suite", "platform").must_equal(
            :name => "starship",
            :speed => 42
          )
        end

        it "merges driver into driver_config if driver with name exists" do
          DataMunger.new(
            {
              :driver_config => {
                :eh => "yep"
              },
              :driver => "zappa"
            },
            {}
          ).driver_data_for("suite", "platform").must_equal(
            :name => "zappa",
            :eh => "yep"
          )
        end

        it "merges driver into driver_config if driver exists" do
          DataMunger.new(
            {
              :driver_plugin => "imold",
              :driver_config => {
                :eh => "yep",
                :color => "pink"
              },
              :driver => {
                :name => "zappa",
                :color => "black"
              }
            },
            {}
          ).driver_data_for("suite", "platform").must_equal(
            :name => "zappa",
            :eh => "yep",
            :color => "black"
          )
        end

        it "returns platform driver name" do
          DataMunger.new(
            {
              :platforms => [
                {
                  :name => "plat",
                  :driver_plugin => "flip"
                }
              ]
            },
            {}
          ).driver_data_for("suite", "plat").must_equal(
            :name => "flip"
          )
        end

        it "returns platform config containing driver hash" do
          DataMunger.new(
            {
              :platforms => [
                {
                  :name => "plat",
                  :driver_plugin => "flip",
                  :driver_config => {
                    :flop => "yep"
                  }
                }
              ]
            },
            {}
          ).driver_data_for("suite", "plat").must_equal(
            :name => "flip",
            :flop => "yep"
          )
        end

        it "returns suite driver name" do
          DataMunger.new(
            {
              :suites => [
                {
                  :name => "sweet",
                  :driver_plugin => "waz"
                }
              ]
            },
            {}
          ).driver_data_for("sweet", "platform").must_equal(
            :name => "waz"
          )
        end

        it "returns suite config containing driver hash" do
          DataMunger.new(
            {
              :suites => [
                {
                  :name => "sweet",
                  :driver_plugin => "waz",
                  :driver_config => {
                    :up => "nope"
                  }
                }
              ]
            },
            {}
          ).driver_data_for("sweet", "platform").must_equal(
            :name => "waz",
            :up => "nope"
          )
        end
      end

      describe "from multiple sources" do

        it "suite into platform into common" do
          DataMunger.new(
            {
              :driver_plugin => "commony",
              :driver_config => {
                :color => "purple",
                :fruit => %w[apple pear],
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
            },
            {}
          ).driver_data_for("sweet", "plat").must_equal(
            :name => "suitey",
            :color => "purple",
            :fruit => ["banana"],
            :vehicle => "car",
            :deep => {
              :common => "junk",
              :platform => "stuff",
              :suite => "things"
            }
          )
        end

        it "platform into common" do
          DataMunger.new(
            {
              :driver_plugin => "commony",
              :driver_config => {
                :color => "purple",
                :fruit => %w[apple pear],
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
            },
            {}
          ).driver_data_for("sweet", "plat").must_equal(
            :name => "platformy",
            :color => "purple",
            :fruit => ["banana"],
            :deep => {
              :common => "junk",
              :platform => "stuff"
            }
          )
        end

        it "suite into common" do
          DataMunger.new(
            {
              :driver_plugin => "commony",
              :driver_config => {
                :color => "purple",
                :fruit => %w[apple pear],
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
            },
            {}
          ).driver_data_for("sweet", "plat").must_equal(
            :name => "suitey",
            :color => "purple",
            :fruit => %w[apple pear],
            :vehicle => "car",
            :deep => {
              :common => "junk",
              :suite => "things"
            }
          )
        end

        it "suite into platform" do
          DataMunger.new(
            {
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
            },
            {}
          ).driver_data_for("sweet", "plat").must_equal(
            :name => "suitey",
            :fruit => ["banana"],
            :vehicle => "car",
            :deep => {
              :platform => "stuff",
              :suite => "things"
            }
          )
        end
      end
    end

    describe "legacy chef paths from suite" do

      LEGACY_CHEF_PATHS = [
        :data_path, :data_bags_path, :environments_path,
        :nodes_path, :roles_path, :encrypted_data_bag_secret_key_path
      ]

      LEGACY_CHEF_PATHS.each do |key|

        it "moves #{key} into provisioner" do
          DataMunger.new(
            {
              :provisioner => "chefy",
              :suites => [
                {
                  :name => "sweet",
                  key => "mypath"
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            key => "mypath"
          )
        end

        it "merges provisioner into data_path if provisioner exists" do
          DataMunger.new(
            {
              :suites => [
                {
                  :name => "sweet",
                  key => "mypath",
                  :provisioner => "chefy"
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "plat").must_equal(
            :name => "chefy",
            key => "mypath"
          )
        end
      end
    end

    describe "legacy require_chef_omnibus from driver" do

      describe "from a single source" do

        it "common driver value moves into provisioner" do
          DataMunger.new(
            {
              :provisioner => "chefy",
              :driver => {
                :name => "starship",
                :require_chef_omnibus => "it's probably fine"
              }
            },
            {}
          ).provisioner_data_for("suite", "platform").must_equal(
            :name => "chefy",
            :require_chef_omnibus => "it's probably fine"
          )
        end

        it "common driver value loses to existing provisioner value" do
          DataMunger.new(
            {
              :provisioner => {
                :name => "chefy",
                :require_chef_omnibus => "it's probably fine"
              },
              :driver => {
                :name => "starship",
                :require_chef_omnibus => "dragons"
              }
            },
            {}
          ).provisioner_data_for("suite", "platform").must_equal(
            :name => "chefy",
            :require_chef_omnibus => "it's probably fine"
          )
        end

        it "suite driver value moves into provisioner" do
          DataMunger.new(
            {
              :suites => [
                {
                  :name => "sweet",
                  :provisioner => "chefy",
                  :driver => {
                    :name => "starship",
                    :require_chef_omnibus => "it's probably fine"
                  }
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "platform").must_equal(
            :name => "chefy",
            :require_chef_omnibus => "it's probably fine"
          )
        end

        it "suite driver value loses to existing provisioner value" do
          DataMunger.new(
            {
              :suites => [
                {
                  :name => "sweet",
                  :provisioner => {
                    :name => "chefy",
                    :require_chef_omnibus => "it's probably fine"
                  },
                  :driver => {
                    :name => "starship",
                    :require_chef_omnibus => "dragons"
                  }
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "platform").must_equal(
            :name => "chefy",
            :require_chef_omnibus => "it's probably fine"
          )
        end

        it "platform driver value moves into provisioner" do
          DataMunger.new(
            {
              :platforms => [
                {
                  :name => "plat",
                  :provisioner => "chefy",
                  :driver => {
                    :name => "starship",
                    :require_chef_omnibus => "it's probably fine"
                  }
                }
              ]
            },
            {}
          ).provisioner_data_for("suite", "plat").must_equal(
            :name => "chefy",
            :require_chef_omnibus => "it's probably fine"
          )
        end

        it "platform driver value loses to existing provisioner value" do
          DataMunger.new(
            {
              :platforms => [
                {
                  :name => "plat",
                  :provisioner => {
                    :name => "chefy",
                    :require_chef_omnibus => "it's probably fine"
                  },
                  :driver => {
                    :name => "starship",
                    :require_chef_omnibus => "dragons"
                  }
                }
              ]
            },
            {}
          ).provisioner_data_for("suite", "plat").must_equal(
            :name => "chefy",
            :require_chef_omnibus => "it's probably fine"
          )
        end
      end
    end

    describe "legacy http_proxy & https_proxy from driver" do

      describe "from a single source" do

        it "common driver value remains in driver" do
          DataMunger.new(
            {
              :provisioner => "chefy",
              :driver => {
                :name => "starship",
                :http_proxy => "http://proxy",
                :https_proxy => "https://proxy"
              }
            },
            {}
          ).driver_data_for("suite", "platform").must_equal(
            :name => "starship",
            :http_proxy => "http://proxy",
            :https_proxy => "https://proxy"
          )
        end

        it "common driver value copies into provisioner" do
          DataMunger.new(
            {
              :provisioner => "chefy",
              :driver => {
                :name => "starship",
                :http_proxy => "http://proxy",
                :https_proxy => "https://proxy"
              }
            },
            {}
          ).provisioner_data_for("suite", "platform").must_equal(
            :name => "chefy",
            :http_proxy => "http://proxy",
            :https_proxy => "https://proxy"
          )
        end

        it "common driver value copies into verifier" do
          DataMunger.new(
            {
              :verifier => "bussy",
              :driver => {
                :name => "starship",
                :http_proxy => "http://proxy",
                :https_proxy => "https://proxy"
              }
            },
            {}
          ).verifier_data_for("suite", "platform").must_equal(
            :name => "bussy",
            :http_proxy => "http://proxy",
            :https_proxy => "https://proxy"
          )
        end

        it "common driver value loses to existing provisioner value" do
          DataMunger.new(
            {
              :provisioner => {
                :name => "chefy",
                :http_proxy => "it's probably fine",
                :https_proxy => "la quinta"
              },
              :driver => {
                :name => "starship",
                :http_proxy => "dragons",
                :https_proxy => "cats"
              }
            },
            {}
          ).provisioner_data_for("suite", "platform").must_equal(
            :name => "chefy",
            :http_proxy => "it's probably fine",
            :https_proxy => "la quinta"
          )
        end

        it "common driver value loses to existing verifier value" do
          DataMunger.new(
            {
              :verifier => {
                :name => "bussy",
                :http_proxy => "it's probably fine",
                :https_proxy => "la quinta"
              },
              :driver => {
                :name => "starship",
                :http_proxy => "dragons",
                :https_proxy => "cats"
              }
            },
            {}
          ).verifier_data_for("suite", "platform").must_equal(
            :name => "bussy",
            :http_proxy => "it's probably fine",
            :https_proxy => "la quinta"
          )
        end

        it "suite driver value remains in driver" do
          DataMunger.new(
            {
              :suites => [
                {
                  :name => "sweet",
                  :provisioner => "chefy",
                  :driver => {
                    :name => "starship",
                    :http_proxy => "it's probably fine",
                    :https_proxy => "la quinta"
                  }
                }
              ]
            },
            {}
          ).driver_data_for("sweet", "platform").must_equal(
            :name => "starship",
            :http_proxy => "it's probably fine",
            :https_proxy => "la quinta"
          )
        end

        it "suite driver value copies into provisioner" do
          DataMunger.new(
            {
              :suites => [
                {
                  :name => "sweet",
                  :provisioner => "chefy",
                  :driver => {
                    :name => "starship",
                    :http_proxy => "it's probably fine",
                    :https_proxy => "la quinta"
                  }
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "platform").must_equal(
            :name => "chefy",
            :http_proxy => "it's probably fine",
            :https_proxy => "la quinta"
          )
        end

        it "suite driver value copies into verifier" do
          DataMunger.new(
            {
              :suites => [
                {
                  :name => "sweet",
                  :verifier => "bussy",
                  :driver => {
                    :name => "starship",
                    :http_proxy => "it's probably fine",
                    :https_proxy => "la quinta"
                  }
                }
              ]
            },
            {}
          ).verifier_data_for("sweet", "platform").must_equal(
            :name => "bussy",
            :http_proxy => "it's probably fine",
            :https_proxy => "la quinta"
          )
        end

        it "suite driver value loses to existing provisioner value" do
          DataMunger.new(
            {
              :suites => [
                {
                  :name => "sweet",
                  :provisioner => {
                    :name => "chefy",
                    :http_proxy => "it's probably fine",
                    :https_proxy => "la quinta"
                  },
                  :driver => {
                    :name => "starship",
                    :http_proxy => "dragons",
                    :https_proxy => "cats"
                  }
                }
              ]
            },
            {}
          ).provisioner_data_for("sweet", "platform").must_equal(
            :name => "chefy",
            :http_proxy => "it's probably fine",
            :https_proxy => "la quinta"
          )
        end

        it "suite driver value loses to existing verifier value" do
          DataMunger.new(
            {
              :suites => [
                {
                  :name => "sweet",
                  :verifier => {
                    :name => "bussy",
                    :http_proxy => "it's probably fine",
                    :https_proxy => "la quinta"
                  },
                  :driver => {
                    :name => "starship",
                    :http_proxy => "dragons",
                    :https_proxy => "cats"
                  }
                }
              ]
            },
            {}
          ).verifier_data_for("sweet", "platform").must_equal(
            :name => "bussy",
            :http_proxy => "it's probably fine",
            :https_proxy => "la quinta"
          )
        end

        it "platform driver value remains in driver" do
          DataMunger.new(
            {
              :platforms => [
                {
                  :name => "plat",
                  :provisioner => "chefy",
                  :driver => {
                    :name => "starship",
                    :http_proxy => "it's probably fine",
                    :https_proxy => "la quinta"
                  }
                }
              ]
            },
            {}
          ).driver_data_for("suite", "plat").must_equal(
            :name => "starship",
            :http_proxy => "it's probably fine",
            :https_proxy => "la quinta"
          )
        end

        it "platform driver value copies into provisioner" do
          DataMunger.new(
            {
              :platforms => [
                {
                  :name => "plat",
                  :provisioner => "chefy",
                  :driver => {
                    :name => "starship",
                    :http_proxy => "it's probably fine",
                    :https_proxy => "la quinta"
                  }
                }
              ]
            },
            {}
          ).provisioner_data_for("suite", "plat").must_equal(
            :name => "chefy",
            :http_proxy => "it's probably fine",
            :https_proxy => "la quinta"
          )
        end

        it "platform driver value copies into verifier" do
          DataMunger.new(
            {
              :platforms => [
                {
                  :name => "plat",
                  :verifier => "bussy",
                  :driver => {
                    :name => "starship",
                    :http_proxy => "it's probably fine",
                    :https_proxy => "la quinta"
                  }
                }
              ]
            },
            {}
          ).verifier_data_for("suite", "plat").must_equal(
            :name => "bussy",
            :http_proxy => "it's probably fine",
            :https_proxy => "la quinta"
          )
        end

        it "platform driver value loses to existing provisioner value" do
          DataMunger.new(
            {
              :platforms => [
                {
                  :name => "plat",
                  :provisioner => {
                    :name => "chefy",
                    :http_proxy => "it's probably fine",
                    :https_proxy => "la quinta"
                  },
                  :driver => {
                    :name => "starship",
                    :http_proxy => "dragons",
                    :https_proxy => "cats"
                  }
                }
              ]
            },
            {}
          ).provisioner_data_for("suite", "plat").must_equal(
            :name => "chefy",
            :http_proxy => "it's probably fine",
            :https_proxy => "la quinta"
          )
        end

        it "platform driver value loses to existing verifier value" do
          DataMunger.new(
            {
              :platforms => [
                {
                  :name => "plat",
                  :verifier => {
                    :name => "bussy",
                    :http_proxy => "it's probably fine",
                    :https_proxy => "la quinta"
                  },
                  :driver => {
                    :name => "starship",
                    :http_proxy => "dragons",
                    :https_proxy => "cats"
                  }
                }
              ]
            },
            {}
          ).verifier_data_for("suite", "plat").must_equal(
            :name => "bussy",
            :http_proxy => "it's probably fine",
            :https_proxy => "la quinta"
          )
        end
      end
    end

    describe "legacy busser blocks to verifier" do

      describe "from a single source" do

        it "merges old common busser name to version into verifier" do
          DataMunger.new(
            {
              :busser => "starship"
            },
            {}
          ).verifier_data_for("suite", "platform").must_equal(
            :name => "busser",
            :version => "starship"
          )
        end

        it "merges old common busser name to version with exising verifier" do
          DataMunger.new(
            {
              :busser => "starship",
              :verifier => {
                :a => "b"
              }
            },
            {}
          ).verifier_data_for("suite", "platform").must_equal(
            :name => "busser",
            :version => "starship",
            :a => "b"
          )
        end

        it "merges old common busser name to version into verifier with name" do
          DataMunger.new(
            {
              :busser => "starship",
              :verifier => "stellar"
            },
            {}
          ).verifier_data_for("suite", "platform").must_equal(
            :name => "stellar",
            :version => "starship"
          )
        end

        it "merges old busser data into verifier with name" do
          DataMunger.new(
            {
              :busser => {
                :a => "b"
              },
              :verifier => "stellar"
            },
            {}
          ).verifier_data_for("suite", "platform").must_equal(
            :name => "stellar",
            :a => "b"
          )
        end

        it "merges old busser data into verifier data" do
          DataMunger.new(
            {
              :busser => {
                :a => "b",
                :both => "legacy"
              },
              :verifier => {
                :name => "stellar",
                :c => "d",
                :both => "modern"
              }
            },
            {}
          ).verifier_data_for("suite", "platform").must_equal(
            :name => "stellar",
            :a => "b",
            :c => "d",
            :both => "modern"
          )
        end

        it "returns platform verifier name" do
          DataMunger.new(
            {
              :platforms => [
                {
                  :name => "plat",
                  :busser => "flip"
                }
              ]
            },
            {}
          ).verifier_data_for("suite", "plat").must_equal(
            :name => "busser",
            :version => "flip"
          )
        end

        it "return platform config containing verifier hash" do
          DataMunger.new(
            {
              :platforms => [
                {
                  :name => "plat",
                  :busser => "flip",
                  :verifier => {
                    :flop => "yep"
                  }
                }
              ]
            },
            {}
          ).verifier_data_for("suite", "plat").must_equal(
            :name => "busser",
            :version => "flip",
            :flop => "yep"
          )
        end

        it "returns suite driver name" do
          DataMunger.new(
            {
              :suites => [
                {
                  :name => "sweet",
                  :busser => "waz"
                }
              ]
            },
            {}
          ).verifier_data_for("sweet", "platform").must_equal(
            :name => "busser",
            :version => "waz"
          )
        end

        it "returns suite config containing verifier hash" do
          DataMunger.new(
            {
              :suites => [
                {
                  :name => "sweet",
                  :busser => "waz",
                  :verifier => {
                    :up => "nope"
                  }
                }
              ]
            },
            {}
          ).verifier_data_for("sweet", "platform").must_equal(
            :name => "busser",
            :version => "waz",
            :up => "nope"
          )
        end
      end

      describe "from multiple sources" do

        it "suite into platform into common" do
          DataMunger.new(
            {
              :busser => {
                :version => "commony",
                :color => "purple",
                :fruit => %w[apple pear],
                :deep => { :common => "junk" }
              },
              :platforms => [
                {
                  :name => "plat",
                  :busser => {
                    :version => "platformy",
                    :fruit => ["banana"],
                    :deep => { :platform => "stuff" }
                  }
                }
              ],
              :suites => [
                {
                  :name => "sweet",
                  :busser => {
                    :version => "suitey",
                    :vehicle => "car",
                    :deep => { :suite => "things" }
                  }
                }
              ]
            },
            {}
          ).verifier_data_for("sweet", "plat").must_equal(
            :name => "busser",
            :version => "suitey",
            :color => "purple",
            :fruit => ["banana"],
            :vehicle => "car",
            :deep => {
              :common => "junk",
              :platform => "stuff",
              :suite => "things"
            }
          )
        end

        it "platform into common" do
          DataMunger.new(
            {
              :busser => {
                :version => "commony",
                :color => "purple",
                :fruit => %w[apple pear],
                :deep => { :common => "junk" }
              },
              :platforms => [
                {
                  :name => "plat",
                  :busser => {
                    :version => "platformy",
                    :fruit => ["banana"],
                    :deep => { :platform => "stuff" }
                  }
                }
              ]
            },
            {}
          ).verifier_data_for("sweet", "plat").must_equal(
            :name => "busser",
            :version => "platformy",
            :color => "purple",
            :fruit => ["banana"],
            :deep => {
              :common => "junk",
              :platform => "stuff"
            }
          )
        end

        it "suite into common" do
          DataMunger.new(
            {
              :busser => {
                :version => "commony",
                :color => "purple",
                :fruit => %w[apple pear],
                :deep => { :common => "junk" }
              },
              :suites => [
                {
                  :name => "sweet",
                  :busser => {
                    :version => "suitey",
                    :vehicle => "car",
                    :deep => { :suite => "things" }
                  }
                }
              ]
            },
            {}
          ).verifier_data_for("sweet", "plat").must_equal(
            :name => "busser",
            :version => "suitey",
            :color => "purple",
            :fruit => %w[apple pear],
            :vehicle => "car",
            :deep => {
              :common => "junk",
              :suite => "things"
            }
          )
        end

        it "suite into platform" do
          DataMunger.new(
            {
              :platforms => [
                {
                  :name => "plat",
                  :busser => {
                    :version => "platformy",
                    :fruit => ["banana"],
                    :deep => { :platform => "stuff" }
                  }
                }
              ],
              :suites => [
                {
                  :name => "sweet",
                  :busser => {
                    :version => "suitey",
                    :vehicle => "car",
                    :deep => { :suite => "things" }
                  }
                }
              ]
            },
            {}
          ).verifier_data_for("sweet", "plat").must_equal(
            :name => "busser",
            :version => "suitey",
            :fruit => ["banana"],
            :vehicle => "car",
            :deep => {
              :platform => "stuff",
              :suite => "things"
            }
          )
        end
      end
    end
  end
end

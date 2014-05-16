# -*- encoding: utf-8 -*-
#
# Author:: Douglas Triggs (<doug@getchef.com>)
#
# Copyright (C) 2014, Chef, inc.
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

module Kitchen

  # A target node which will be configured to run tests and then...  Run them.  This
  # is needed for multi-host test configurations, namely those using the kitchen
  # metal driver which will attempt to run tests on any configured nodes.
  #
  # @author Douglas Triggs <doug@getchef.com>
  class Node

    # @return [String] logical name of this node
    attr_reader :name

    # Constructs a new platform.
    #
    # @param [Hash] options configuration for a new node
    # @option options [String] :name logical name of this node (**Required**)
    # @option options [String] :test_base_path test base path (**Required**)
    # @option options [String] :configured_test_base_path indicates if test path was
    #   inherited or configured directly
    def initialize(options = {})
      @name = options.fetch(:name) do
        raise ClientError, "Node#new requires option :name"
      end
      @test_base_path = options.fetch(:test_base_path) do
        raise ClientError, "Node#new requires option :test_base_path"
      end
      @configured_test_base_path = options.fetch(:configured_test_base_path) do
        @configured_test_base_path = false
      end
    end

    # Returns the test_base_path (i.e., the path to the tests) for this node
    #
    # If specifically configured for this node, send that, otherwise append the
    # node name to the suite-wide test path
    def test_base_path
      if @configured_test_base_path
        @test_base_path
      else
        "#{@test_base_path}/#{@name}"
      end
    end
  end
end

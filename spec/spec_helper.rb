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

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/spec'

SimpleCov.at_exit do
  SimpleCov.result.format!
  if SimpleCov.result.covered_percent < 66
    warn "Coverage is slipping: #{SimpleCov.result.covered_percent.to_i}%"
    exit 1
  end
end

require_relative '../lib/test-kitchen'

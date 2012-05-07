#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
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

require 'ripper'
require 'test-kitchen/cli'
require 'test-kitchen/dsl'
require 'test-kitchen/project'
require 'test-kitchen/runner'
require 'test-kitchen/version'

module TestKitchen

  # The source root is the path to the root directory of
  # the test-kitchen gem.
  def self.source_root
    @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
  end

end

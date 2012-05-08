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

require 'test-kitchen'

module TestKitchen

  module Project
    describe CookbookCopy do
      let(:copier) { Class.new{ include CookbookCopy }.new }
      describe "#destination_paths" do
        it "replaces the old path prefix with the new path prefix" do
          copier.destination_paths('/code/my-cookbook', [
            '/code/my-cookbook/attributes',
            '/code/my-cookbook/attributes/default.rb',
            '/code/my-cookbook/metadata.rb',
            '/code/my-cookbook/recipes',
            '/code/my-cookbook/recipes/default.rb'
          ], '/foo/bar').must_equal([
            '/foo/bar/attributes',
            '/foo/bar/attributes/default.rb',
            '/foo/bar/metadata.rb',
            '/foo/bar/recipes',
            '/foo/bar/recipes/default.rb'
          ])
        end
      end
    end
  end

end

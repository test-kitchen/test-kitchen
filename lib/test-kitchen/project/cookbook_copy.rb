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

module TestKitchen
  module Project
    module CookbookCopy

      # This is a workaround to allow the top-level containing cookbook
      # to be copied to the kitchen tmp subdirectory.
      def copy_cookbook_under_test(root_path, tmp_path)
        cookbook_path = root_path.parent.parent
        source_paths = source_paths_excluding_test_dir(cookbook_path)
        dest_path = File.join(tmp_path, 'cookbook_under_test')
        copy_paths(source_paths, dest_path,
          destination_paths(cookbook_path, source_paths, dest_path))
        dest_path
      end

      def source_paths_excluding_test_dir(cookbook_path)
        paths_from = Find.find(cookbook_path).reject do |path|
          Find.prune if ['.git', 'test'].map do |dir|
            File.join(cookbook_path, dir)
          end.include?(path)
        end.drop(1)
      end

      def destination_paths(cookbook_path, paths_from, dest_path)
        paths_from.map do |file|
          File.join(dest_path,
            file.to_s.sub(%r{^#{Regexp.escape(cookbook_path.to_s)}/}, ''))
        end
      end

      def copy_paths(source_paths, dest_path, dest_paths)
        FileUtils.mkdir_p(dest_path)
        source_paths.each_with_index do |from_path, index|
          FileUtils.cp_r(from_path, dest_paths[index])
        end
      end

    end
  end
end

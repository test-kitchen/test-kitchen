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

module TestKitchen
  module Project
    class Cookbook < Ruby

      include CookbookCopy
      include SupportedPlatforms

      attr_writer :lint
      attr_writer :supported_platforms

      def initialize(name, &block)
        super(name, &block)
      end

      def lint(arg=nil)
        set_or_return(:lint, arg, {:default => true})
      end

      def language(arg=nil)
        "chef"
      end

      def preflight_command(runtime = nil)
        return nil unless lint
        parent_dir = File.join(root_path, '..')
        cmd = "knife cookbook test -o #{parent_dir} #{name}"
        cmd << " && foodcritic -f ~FC007 -f correctness #{root_path}"
        cmd
      end

      def test_command(runtime=nil)
        %q{#{cd} && if [ -d "features" ]; then #{path} bundle exec cucumber -t @#{name} features; fi}
      end

      def supported_platforms
        @supported_platforms ||= extract_supported_platforms(
          File.read(File.join(root_path, 'metadata.rb')))
      end

      def non_buildable_platforms(platform_names)
        supported_platforms.sort - platform_names.map do |platform|
          platform.split('-').first
        end.sort.uniq
      end

      def each_build(platforms, &block)
        if supported_platforms.empty?
          super(platforms, &block)
        else
          super(platforms.select do |platform|
            supported_platforms.any? do |supported|
              platform.start_with?("#{supported}-")
            end
          end, &block)
        end
      end

      def cookbook_path(root_path, tmp_path)
        @cookbook_path ||= copy_cookbook_under_test(root_path, tmp_path)
      end

      private

      def cd
        "cd #{File.join(guest_test_root, 'test')}"
      end

      def path
        'PATH=$PATH:/var/lib/gems/1.8/bin'
      end

    end
  end
end

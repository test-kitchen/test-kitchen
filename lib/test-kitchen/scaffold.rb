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

require 'fileutils'
require 'chef/cookbook/metadata'

module TestKitchen

  class Scaffold

    def generate(output_dir)

      scaffold_file '.gitignore',
        <<-eos
          .bundle
          .cache
          .kitchen
          bin
        eos

      scaffold_file 'Gemfile',
        <<-eos
          source :rubygems

          gem 'test-kitchen'
        eos

      scaffold_file 'test/kitchen/Kitchenfile',
        <<-eos
          #{project_type(output_dir)} "#{project_name(output_dir)}" do

          end
        eos
    end

    private

    def project_name(output_dir)
      if project_type(output_dir) =~ /cookbook/
        get_cookbook_name
      else
        File.basename(output_dir)
      end
    end

    def get_cookbook_name()
      md = Chef::Cookbook::Metadata.new
      md.from_file(File.join(output_dir, 'metadata.rb'))
      md.name
    end

    def project_type(output_dir)
      if File.exists?(File.join(output_dir, 'metadata.rb'))
        'cookbook'
      else
        'integration_test'
      end
    end

    def scaffold_file(path, content)
      FileUtils.mkdir_p(File.dirname(path))
      unless File.exists?(path)
        File.open(path, 'w') {|f| f.write(content.gsub(/^ {10}/, '')) }
      end
    end

  end

end

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

require 'thor/group'
require 'thor/util'

module Kitchen

  module Generator

    # A generator to create a new Kitchen Driver gem project.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class NewPlugin < Thor::Group

      include Thor::Actions

      argument :plugin_name

      class_option :license, :aliases => "-l", :default => "apachev2",
        :desc => "License type for gem (apachev2, mit, gplv3, gplv2, reserved)"

      def new_plugin
        if ! run("command -v bundle", :verbose => false)
          die "Bundler must be installed and on your PATH: `gem install bundler'"
        end

        @plugin_name = plugin_name
        @gem_name = "kitchen-#{plugin_name}"
        @gemspec = "#{gem_name}.gemspec"
        @klass_name = ::Thor::Util.camel_case(plugin_name)
        @constant = ::Thor::Util.snake_case(plugin_name).upcase
        @license = options[:license]
        @author = %x{git config user.name}.chomp
        @email = %x{git config user.email}.chomp
        @year = Time.now.year

        create_plugin
      end

      private

      attr_reader :plugin_name, :gem_name, :gemspec, :klass_name,
        :constant, :license, :author, :email, :year

      def create_plugin
        run("bundle gem #{gem_name}") unless File.directory?(gem_name)

        inside(gem_name) do
          update_gemspec
          update_gemfile
          update_rakefile
          create_src_files
          cleanup
          create_license
          add_git_files
        end
      end

      def update_gemspec
        gsub_file(gemspec, %r{require '#{gem_name}/version'},
          %{require 'kitchen/driver/#{plugin_name}_version.rb'})
        gsub_file(gemspec, %r{Kitchen::#{klass_name}::VERSION},
          %{Kitchen::Driver::#{constant}_VERSION})
        gsub_file(gemspec, %r{(gem\.executables\s*) =.*$},
          '\1 = []')
        gsub_file(gemspec, %r{(gem\.description\s*) =.*$},
          '\1 = "' + "Kitchen::Driver::#{klass_name} - " +
            "A Kitchen Driver for #{klass_name}\"")
        gsub_file(gemspec, %r{(gem\.summary\s*) =.*$},
          '\1 = gem.description')
        gsub_file(gemspec, %r{(gem\.homepage\s*) =.*$},
          '\1 = "https://github.com/opscode/' +
            "#{gem_name}/\"")
        insert_into_file(gemspec,
          "\n  gem.add_dependency 'test-kitchen'\n", :before => "end\n")
        insert_into_file(gemspec,
          "\n  gem.add_development_dependency 'cane'\n", :before => "end\n")
        insert_into_file(gemspec,
          "  gem.add_development_dependency 'tailor'\n", :before => "end\n")
      end

      def update_gemfile
        append_to_file("Gemfile", "\ngroup :test do\n  gem 'rake'\nend\n")
      end

      def update_rakefile
        append_to_file("Rakefile", <<-RAKEFILE.gsub(/^ {10}/, ''))
          require 'cane/rake_task'
          require 'tailor/rake_task'

          desc "Run cane to check quality metrics"
          Cane::RakeTask.new

          Tailor::RakeTask.new

          task :default => [ :cane, :tailor ]
        RAKEFILE
      end

      def create_src_files
        license_comments = rendered_license.gsub(/^/, '# ').gsub(/\s+$/, '')

        empty_directory("lib/kitchen/driver")
        create_template("plugin/version.rb",
          "lib/kitchen/driver/#{plugin_name}_version.rb",
          :klass_name => klass_name, :constant => constant,
          :license => license_comments)
        create_template("plugin/driver.rb",
          "lib/kitchen/driver/#{plugin_name}.rb",
          :klass_name => klass_name, :license => license_comments,
          :author => author, :email => email)
      end

      def rendered_license
        TemplateRenderer.render("plugin/license_#{license}",
          :author => author, :email => email, :year => year)
      end

      def create_license
        dest_file = case license
        when "mit" then "LICENSE.txt"
        when "apachev2", "reserved" then "LICENSE"
        when "gplv2", "gplv3" then "COPYING"
        else
          raise ArgumentError, "No such license #{license}"
        end

        create_file(dest_file, rendered_license)
      end

      def cleanup
        %W(LICENSE.txt lib/#{gem_name}/version.rb lib/#{gem_name}.rb).each do |f|
          run("git rm -f #{f}") if File.exists?(f)
        end
        remove_dir("lib/#{gem_name}")
      end

      def add_git_files
        run("git add .")
      end

      def create_template(template, destination, data = {})
        create_file(destination, TemplateRenderer.render(template, data))
      end

      # Renders an ERB template with a hash of template variables.
      #
      # @author Fletcher Nichol <fnichol@nichol.ca>
      class TemplateRenderer < OpenStruct

        def self.render(template, data = {})
          renderer = new(template, data)
          yield renderer if block_given?
          renderer.render
        end

        def initialize(template, data = {})
          super()
          data[:template] = template
          data.each { |key, value| send("#{key}=", value) }
        end

        def render
          ERB.new(IO.read(template_file)).result(binding)
        end

        private

        def template_file
          Kitchen.source_root.join("templates", "#{template}.erb").to_s
        end
      end
    end
  end
end

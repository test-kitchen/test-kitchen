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

module Kitchen

  module Generator

    # A project initialization generator, to help prepare a cookbook project
    # for testing with Kitchen.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Init < Thor::Group

      include Thor::Actions

      def init
        create_file ".kitchen.yml", default_yaml

        rakedoc = <<-RAKE.gsub(/^ {10}/, '')

          begin
            require 'kitchen/rake_tasks'
            Kitchen::RakeTasks.new
          rescue LoadError
            puts ">>>>> Kitchen gem not loaded, omitting tasks" unless ENV['CI']
          end
        RAKE
        append_to_file("Rakefile", rakedoc) if init_rakefile?

        thordoc = <<-THOR.gsub(/^ {10}/, '')

          begin
            require 'kitchen/thor_tasks'
            Kitchen::ThorTasks.new
          rescue LoadError
            puts ">>>>> Kitchen gem not loaded, omitting tasks" unless ENV['CI']
          end
        THOR
        append_to_file("Thorfile", thordoc) if init_thorfile?

        empty_directory "test/integration/default" if init_test_dir?
        append_to_gitignore(".kitchen/")
        append_to_gitignore(".kitchen.local.yml")
        add_plugins
      end

      private

      def default_yaml
        url_base = "https://opscode-vm.s3.amazonaws.com/vagrant/boxes"
        platforms = [
          { :n => 'ubuntu', :vers => %w(12.04 10.04), :rl => "recipe[apt]" },
          { :n => 'centos', :vers => %w(6.3 5.8), :rl => "recipe[yum::epel]" },
        ]
        platforms = platforms.map do |p|
          p[:vers].map do |v|
            { 'name' => "#{p[:n]}-#{v}",
              'driver_config' => {
                'box' => "opscode-#{p[:n]}-#{v}",
                'box_url' => "#{url_base}/opscode-#{p[:n]}-#{v}.box"
              },
              'run_list' => Array(p[:rl])
            }
          end
        end.flatten
        cookbook_name = if File.exists?(File.expand_path('metadata.rb'))
          MetadataChopper.extract('metadata.rb').first
        else
          nil
        end
        run_list = cookbook_name ? "recipe[#{cookbook_name}]" : nil

        { 'driver_plugin' => 'vagrant',
          'platforms' => platforms,
          'suites' => [
            { 'name' => 'default',
              'run_list' => Array(run_list),
              'attributes' => Hash.new
            },
          ]
        }.to_yaml
      end

      def init_rakefile?
        File.exists?("Rakefile") &&
          IO.readlines("Rakefile").grep(%r{require 'kitchen/rake_tasks'}).empty?
      end

      def init_thorfile?
        File.exists?("Thorfile") &&
          IO.readlines("Thorfile").grep(%r{require 'kitchen/thor_tasks'}).empty?
      end

      def init_test_dir?
        Dir.glob("test/integration/*").select { |d| File.directory?(d) }.empty?
      end

      def append_to_gitignore(line)
        create_file(".gitignore") unless File.exists?(".gitignore")

        if IO.readlines(".gitignore").grep(%r{^#{line}}).empty?
          append_to_file(".gitignore", "#{line}\n")
        end
      end

      def add_plugins
        prompt_add  = "Add a Driver plugin to your Gemfile? (y/n)>"
        prompt_name = "Enter gem name, `list', or `skip'>"

        if yes?(prompt_add, :green)
          list_plugins while (plugin = ask(prompt_name, :green)) == "list"
          return if plugin == "skip"
          begin
            append_to_file(
              "Gemfile", %{gem '#{plugin}', :group => :integration\n}
            )
            say "You must run `bundle install' to fetch any new gems.", :red
          rescue Errno::ENOENT
            warn %{You do not have an existing Gemfile}
            warn %{Exiting...}
            exit 1
          end
        end
      end

      def list_plugins
        specs = fetch_gem_specs.map { |t| t.first }.map { |t| t[0, 2] }.
          sort { |x, y| x[0] <=> y[0] }
        specs = specs[0, 49].push(["...", "..."]) if specs.size > 49
        specs = specs.unshift(["Gem Name", "Latest Stable Release"])
        print_table(specs, :indent => 4)
      end

      def fetch_gem_specs
        require 'rubygems/spec_fetcher'
        req = Gem::Requirement.default
        dep = Gem::Deprecate.skip_during do
          Gem::Dependency.new(/kitchen-/i, req)
        end
        fetcher = Gem::SpecFetcher.fetcher

        specs = fetcher.find_matching(dep, false, false, false)
      end
    end
  end
end

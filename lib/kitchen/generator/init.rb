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

      class_option :driver, :type => :array, :aliases => "-d",
        :default => "kitchen-vagrant",
        :desc => <<-D.gsub(/^\s+/, '').gsub(/\n/, ' ')
          One or more Kitchen Driver gems to be installed or added to a
          Gemfile
        D

      class_option :create_gemfile, :type => :boolean, :default => false,
        :desc => <<-D.gsub(/^\s+/, '').gsub(/\n/, ' ')
          Whether or not to create a Gemfile if one does not exist.
          Default: false
        D

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
        prepare_gemfile if File.exists?("Gemfile") || options[:create_gemfile]
        add_drivers

        if @display_bundle_msg
          say "You must run `bundle install' to fetch any new gems.", :red
        end
      end

      private

      def default_yaml
        cookbook_name = if File.exists?(File.expand_path('metadata.rb'))
          MetadataChopper.extract('metadata.rb').first
        else
          nil
        end
        run_list = cookbook_name ? "recipe[#{cookbook_name}]" : nil
        driver_plugin = Array(options[:driver]).first || 'dummy'

        { 'driver_plugin' => driver_plugin.sub(/^kitchen-/, ''),
          'platforms' => platforms_hash,
          'suites' => [
            { 'name' => 'default',
              'run_list' => Array(run_list),
              'attributes' => Hash.new
            },
          ]
        }.to_yaml
      end

      def platforms_hash
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
      end

      def init_rakefile?
        File.exists?("Rakefile") &&
          not_in_file?("Rakefile", %r{require 'kitchen/rake_tasks'})
      end

      def init_thorfile?
        File.exists?("Thorfile") &&
          not_in_file?("Thorfile", %r{require 'kitchen/thor_tasks'})
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

      def prepare_gemfile
        create_gemfile_if_missing
        add_gem_to_gemfile
      end

      def create_gemfile_if_missing
        unless File.exists?("Gemfile")
          create_file("Gemfile", %{source 'https://rubygems.org'\n\n})
        end
      end

      def add_gem_to_gemfile
        if not_in_file?("Gemfile", %r{gem 'test-kitchen'})
          append_to_file("Gemfile",
            %{gem 'test-kitchen', :group => :integration\n})
          @display_bundle_msg = true
        end
      end

      def add_drivers
        return if options[:driver].nil? || options[:driver].empty?
        display_warning = false

        Array(options[:driver]).each do |driver_gem|
          if File.exists?("Gemfile") || options[:create_gemfile]
            add_driver_to_gemfile(driver_gem)
          else
            install_gem(driver_gem)
          end
        end
      end

      def add_driver_to_gemfile(driver_gem)
        if not_in_file?("Gemfile", %r{gem '#{driver_gem}'})
          append_to_file("Gemfile",
            %{gem '#{driver_gem}', :group => :integration\n})
          @display_bundle_msg = true
        end
      end

      def install_gem(driver_gem)
        Bundler.with_clean_env do
          run "gem install #{driver_gem}"
        end
      end

      def not_in_file?(filename, regexp)
        IO.readlines(filename).grep(regexp).empty?
      end
    end
  end
end

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

require "rubygems/gem_runner"
require "thor/group"

module Kitchen
  module Generator
    # A project initialization generator, to help prepare a cookbook project
    # for testing with Kitchen.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    class Init < Thor::Group
      include Thor::Actions

      class_option :driver,
                   type: :array,
                   aliases: "-D",
                   default: %w{kitchen-vagrant},
                   desc: <<-D.gsub(/^\s+/, "").tr("\n", " ")
          One or more Kitchen Driver gems to be installed or added to a
          Gemfile
        D

      class_option :provisioner,
                   type: :string,
                   aliases: "-P",
                   default: "chef_solo",
                   desc: <<-D.gsub(/^\s+/, "").tr("\n", " ")
          The default Kitchen Provisioner to use
        D

      class_option :create_gemfile,
                   type: :boolean,
                   default: false,
                   desc: <<-D.gsub(/^\s+/, "").tr("\n", " ")
          Whether or not to create a Gemfile if one does not exist.
          Default: false
        D

      # Invoke the command.
      def init
        self.class.source_root(Kitchen.source_root.join("templates", "init"))

        create_kitchen_yaml
        create_chefignore
        prepare_rakefile
        prepare_thorfile
        create_test_dir
        prepare_gitignore
        prepare_gemfile
        display_bundle_message
      end

      private

      # Creates the `.kitchen.yml` file.
      #
      # @api private
      def create_kitchen_yaml
        cookbook_name = if File.exist?(File.expand_path("metadata.rb"))
                          MetadataChopper.extract("metadata.rb").first
                        end
        run_list = cookbook_name ? "recipe[#{cookbook_name}::default]" : nil
        driver_plugin = Array(options[:driver]).first || "dummy"

        template("kitchen.yml.erb", ".kitchen.yml",
                 driver_plugin: driver_plugin.sub(/^kitchen-/, ""),
                 provisioner: options[:provisioner],
                 run_list: Array(run_list)
                )
      end

      # Creates the `chefignore` file.
      #
      # @api private
      def create_chefignore
        template("chefignore.erb", "chefignore")
      end

      # @return [true,false] whether or not a Gemfile needs to be initialized
      # @api private
      def init_gemfile?
        File.exist?(File.join(destination_root, "Gemfile")) ||
          options[:create_gemfile]
      end

      # @return [true,false] whether or not a Rakefile needs to be initialized
      # @api private
      def init_rakefile?
        File.exist?(File.join(destination_root, "Rakefile")) &&
          not_in_file?("Rakefile", %r{require 'kitchen/rake_tasks'})
      end

      # @return [true,false] whether or not a Thorfile needs to be initialized
      # @api private
      def init_thorfile?
        File.exist?(File.join(destination_root, "Thorfile")) &&
          not_in_file?("Thorfile", %r{require 'kitchen/thor_tasks'})
      end

      # @return [true,false] whether or not a test directory needs to be
      #   initialized
      # @api private
      def init_test_dir?
        Util.list_directory("test/integration/").select { |d| File.directory?(d) }.empty?
      end

      # @return [true,false] whether or not a `.gitignore` file needs to be
      #   initialized
      # @api private
      def init_git?
        File.directory?(File.join(destination_root, ".git"))
      end

      # Prepares a Rakefile.
      #
      # @api private
      def prepare_rakefile
        return unless init_rakefile?

        rakedoc = <<-RAKE.gsub(/^ {10}/, "")

          begin
            require 'kitchen/rake_tasks'
            Kitchen::RakeTasks.new
          rescue LoadError
            puts '>>>>> Kitchen gem not loaded, omitting tasks' unless ENV['CI']
          end
        RAKE
        append_to_file(File.join(destination_root, "Rakefile"), rakedoc)
      end

      # Prepares a Thorfile.
      #
      # @api private
      def prepare_thorfile
        return unless init_thorfile?

        thordoc = <<-THOR.gsub(/^ {10}/, "")

          begin
            require 'kitchen/thor_tasks'
            Kitchen::ThorTasks.new
          rescue LoadError
            puts '>>>>> Kitchen gem not loaded, omitting tasks' unless ENV['CI']
          end
        THOR
        append_to_file(File.join(destination_root, "Thorfile"), thordoc)
      end

      # Create the default test directory
      #
      # @api private
      def create_test_dir
        empty_directory "test/integration/default" if init_test_dir?
      end

      # Prepares the .gitignore file
      #
      # @api private
      def prepare_gitignore
        return unless init_git?

        append_to_gitignore(".kitchen/")
        append_to_gitignore(".kitchen.local.yml")
      end

      # Appends a line to the .gitignore file.
      #
      # @api private
      def append_to_gitignore(line)
        create_file(".gitignore") unless File.exist?(File.join(destination_root, ".gitignore"))

        if IO.readlines(File.join(destination_root, ".gitignore")).grep(/^#{line}/).empty?
          append_to_file(".gitignore", "#{line}\n")
        end
      end

      # Prepares a Gemfile.
      #
      # @api private
      def prepare_gemfile
        return unless init_gemfile?

        create_gemfile_if_missing
        add_gem_to_gemfile
      end

      # Creates a Gemfile if missing
      #
      # @api private
      def create_gemfile_if_missing
        unless File.exist?(File.join(destination_root, "Gemfile"))
          create_file("Gemfile", %{source "https://rubygems.org"\n\n})
        end
      end

      # Appends entries to a Gemfile.
      #
      # @api private
      def add_gem_to_gemfile
        if not_in_file?("Gemfile", /gem ('|")test-kitchen('|")/)
          append_to_file("Gemfile", %{gem "test-kitchen"\n})
          @display_bundle_msg = true
        end
      end

      # Displays a bundle warning message to the user.
      #
      # @api private
      def display_bundle_message
        if @display_bundle_msg
          say "You must run `bundle install' to fetch any new gems.", :red
        end
      end

      # Determines whether or not a pattern is found in a file.
      #
      # @param filename [String] filename to read
      # @param regexp [Regexp] a regular expression
      # @return [true,false] whether or not a pattern is found in a file
      # @api private
      def not_in_file?(filename, regexp)
        IO.readlines(File.join(destination_root, filename)).grep(regexp).empty?
      end

      # Save off any Bundler/Ruby-related environment variables so that the
      # yielded block can run "bundler-free" (and restore at the end).
      #
      # @api private
      def unbundlerize
        keys = ENV.keys.select { |key| key =~ /^BUNDLER?_/ } + %w{RUBYOPT}

        keys.each { |key| ENV["__#{key}"] = ENV[key]; ENV.delete(key) }
        yield
        keys.each { |key| ENV[key] = ENV.delete("__#{key}") }
      end
    end
  end
end

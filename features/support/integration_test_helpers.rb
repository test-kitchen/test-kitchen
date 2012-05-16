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

  module Helpers

    def available_platforms
      @platforms
    end

    def assert_only_platforms_converged(platform_prefixes)
      expected_platforms.each do |platform|
        if platform_prefixes.any?{|p| platform.start_with?("#{p}-")}
          assert(converged?(platform, 'default'),
            "Expected platform '#{platform}' to have been converged.")
        else
          refute(converged?(platform, 'default'),
            "Expected platform '#{platform}' not to have been converged.")
        end
      end
    end

    # Setup a cookbook project that uses test-kitchen for integration testing
    def chef_cookbook(options = {})
      options = {:type => :real_world, :setup => true}.merge(options)
      case options[:type]
        when :real_world
          clone_cookbook_repository('apache2', '3ceb3d3')
          merge_apache2_test
          add_gem_file('apache2')
          add_test_setup_recipe('apache2', 'apache2_test')
        when :real_world_testless
          clone_cookbook_repository('vim', '789bfc')
        when :newly_generated
          generate_new_cookbook(options[:name], options[:path])
          add_platform_metadata('example', options[:supports_type]) if options[:supports_type]
          add_gem_file(options[:name])
          add_test_setup_recipe('example', 'example_test') if options[:setup]
        else
          fail "Unknown type: #{options[:type]}"
      end
      introduce_syntax_error if options[:malformed]
      introduce_correctness_problem if options[:lint_problem] == :correctness
      introduce_style_problem if options[:lint_problem] == :style
    end

    def configuration_recipe(cookbook_name, test_cookbook, configuration)
      write_file "#{cookbook_name}/test/kitchen/cookbooks/#{test_cookbook}/recipes/#{configuration}.rb", %q{
        Chef::Log.info("This is a configuration recipe.")
      }
    end

    def converged?(platform, recipe)
      provision_banner = 'Provisioning Linux Container: '
      converges = all_output.split(/#{Regexp.escape(provision_banner)}/)
      converges.any? do |converge|
        converge.start_with?(platform) &&
          converge.match(/Run List is .*#{Regexp.escape("example_test::#{recipe}")}/)
      end
    end

    def expected_platforms
      ['ubuntu-11.04', 'centos-6.2']
    end

    def list_platforms
      cd 'apache2'
      run_simple(unescape("bundle exec kitchen platform list"))
      @platforms = all_output.split("\n").map(&:lstrip)
    end

    def ruby_project
      run_simple('git clone --quiet https://github.com/opscode/mixlib-shellout.git')
      cd('mixlib-shellout')
      run_simple('git checkout --quiet 3a72a18a9151b160cea1e47f226fc45ba295ed8e') #Ok
      #run_simple('git checkout --quiet d67c9a9494c74e6443262024d0e46e83df1af6c6') #Broken
      write_file 'Gemfile', %q{
        source :rubygems
        gemspec :name => "mixlib-shellout"

        group(:test) do

          gem "rspec_junit_formatter"
          gem 'awesome_print'

        end

        group(:kitchen) do
          gem "test-kitchen", :path => '../../..'
        end
      }
      cd '..'
    end

    def define_integration_tests(options={})
      options = {
        :project_type => 'cookbook',
        :name => 'apache2',
        :configurations => []
      }.merge(options)

      case options[:project_type]
        when "project"
          options[:name] = 'mixlib-shellout'
          write_file "#{File.join(options[:name], 'Kitchenfile')}", %Q{
            integration_test "#{options[:name]}" do
              language 'ruby'
              runner 'vagrant'
              runtimes ['1.8.7','1.9.2']
              install 'bundle install --without kitchen'
              script 'bundle exec rspec spec'
            #{'end' unless options[:malformed]}
          }
        when "cookbook"
          # TODO: Template this properly
          dsl = %Q{cookbook "#{options[:name]}" do\n}
          options[:configurations].each do |configuration|
            dsl << %Q{  configuration "#{configuration}"\n}
          end
          if options[:name] == 'apache2'
            dsl << %Q{run_list_extras ['apache2_test::setup']\n}
          end
          dsl << 'end' unless options[:malformed]
          write_file "#{options[:name]}/test/kitchen/Kitchenfile", dsl
          cd options[:name]
        else
          fail "Unrecognised project type: #{options[:project_type]}"
      end
    end

    def run_integration_tests
      run_simple(unescape("bundle install"))
      run_simple(unescape("bundle exec kitchen test"), false)
    end

    def scaffold_tests
      run_simple(unescape("bundle install"))
      run_simple(unescape("bundle exec kitchen init"))
    end

    def kitchenfile_error_shown?
      !! (all_output =~ /Your Kitchenfile could not be loaded. Please check it for errors./)
    end

    def lint_correctness_error_shown?
      !! (all_output =~ /Your cookbook had lint failures./)
    end

    def missing_config_recipe_error_shown?(configuration)
      !! (all_output =~ /Your project is missing a test recipe for configuration: #{Regexp.escape(configuration)}/)
    end

    def syntax_error_shown?
      !! (all_output =~ %r{FATAL: Cookbook file recipes/default.rb has a ruby syntax error})
    end

    def tests_run?
      !! (all_output =~ /passed/)
    end

    def unrecognised_platform_warning_shown?(platform_name)
      !! (all_output =~ %r{Cookbook metadata specifies an unrecognised platform that will not be tested: #{Regexp.escape(platform_name)}})
    end

    private

    def clone_cookbook_repository(cookbook_name, sha)
      run_simple("git clone --quiet git://github.com/opscode-cookbooks/#{cookbook_name}.git")
      cd(cookbook_name)
      run_simple("git checkout --quiet #{sha}")
      cd '..'
    end

    def merge_apache2_test
      cd 'apache2'
      run_simple('git clone --quiet git://github.com/kotiri/apache2_test.git test/kitchen/cookbooks/apache2_test')
      run_simple('mv test/kitchen/cookbooks/apache2_test/features test/features')
      cd '..'
    end

    def introduce_syntax_error
      append_to_file('recipes/default.rb', %q{
        end # Bang!
      })
    end

    def introduce_correctness_problem
      append_to_file('recipes/default.rb', %q{
        # This resource should trigger a FC006 warning
        directory "/var/lib/foo" do
          owner "root"
          group "root"
          mode 644
          action :create
        end
      })
    end

    def introduce_style_problem
      append_to_file('recipes/default.rb', %q{
        path = "/var/lib/foo"
        directory "#{path}" do
          action :create
        end
      })
    end

    def add_gem_file(cookbook_name)
      gems = %w{cucumber minitest}
      gems += %w{nokogiri httparty} if cookbook_name == 'apache2'
      write_file "#{cookbook_name}/test/Gemfile", %Q{
        source :rubygems

        #{gems.map{|g| "gem '#{g}'"}.join("\n")}

        group(:kitchen) do
          gem "test-kitchen", :path => '../../../..'
        end
      }
    end

    def add_platform_metadata(cookbook_name, supports_type)
      supports = case supports_type
        when :literal then "supports 'ubuntu'"
        when :wordlist then %q{
          %w{ubuntu centos}.each do |os|
            supports os
          end
        }
        when :includes_unrecognised then %q{
          %w{ubuntu beos centos}.each do |os|
            supports os
          end
        }
        else fail "Unrecognised supports_type: #{supports_type}"
      end
      append_to_file("#{cookbook_name}/metadata.rb", "#{supports}\n")
    end

    def add_test_setup_recipe(cookbook_name, test_cookbook)
      write_file "#{cookbook_name}/test/kitchen/cookbooks/#{test_cookbook}/recipes/setup.rb", %q{
        case node.platform
          when 'ubuntu'
            %w{libxml2 libxml2-dev libxslt1-dev}.each do |pkg|
              package pkg do
                action :install
              end
            end
          when 'centos'
            %w{gcc make ruby-devel libxml2 libxml2-devel libxslt libxslt-devel}.each do |pkg|
              package pkg do
                action :install
              end
            end
          end

        package "curl" do
          action :install
        end
      }
    end

    module CommandLine

      def assert_command_banner_present(subcommand)
        all_output.must_match /^kitchen #{Regexp.escape(subcommand)} \(options\)/
      end

      def assert_correct_subcommands_shown
        subcommands_shown(all_output).must_equal expected_subcommands
      end

      def assert_option_present(flag, description)
        displayed_options.must_include [flag, description]
      end

      def command_help(subcommand)
        run_simple(unescape("bundle exec kitchen #{subcommand} --help"))
        @subcommand = subcommand
      end

      def current_subcommand
        @subcommand
      end

      def displayed_options
        all_output.split("\n").drop(1).map do |option|
          option.split(/   /).reject{|t| t.empty?}.map{|o| o.strip}
        end
      end

      def expected_subcommands
        %w{destroy init platform project ssh status test}
      end

      def generate_new_cookbook(name, path)
        run_simple("knife cookbook create -o #{path} #{name}")
      end

      def option_flags
        displayed_options.map{|o| o.first}.compact.select do |o|
          o.start_with?('-')
        end.map{|o| o.split('--')[1].split(' ').first}
      end

      def subcommands_shown(output)
        output.split("\n").select{|line|line.start_with? 'kitchen '}.map do |line|
          line.split(' ')[1]
        end.sort
      end

    end
  end
end

World(TestKitchen::Helpers)
World(TestKitchen::Helpers::CommandLine)

module TestKitchen

  module Helpers

    def configuration_recipe(cookbook_name, test_cookbook, configuration)
      write_file "#{cookbook_name}/test/kitchen/cookbooks/#{test_cookbook}/recipes/#{configuration}.rb", %q{
        Chef::Log.info("This is a configuration recipe.")
      } 
    end

    # Setup a cookbook project that uses test-kitchen for integration testing
    def chef_cookbook(options = {})
      options = {:type => :real_world}.merge(options)
      case options[:type]
        when :real_world
          clone_and_merge_repositories
          add_gem_file('apache2')
          add_test_setup_recipe
        when :newly_generated
          generate_new_cookbook(options[:name], options[:path])
          add_gem_file(options[:name])
        else
          fail "Unknown type: #{options[:type]}"
      end
      introduce_syntax_error if options[:malformed]
      introduce_correctness_problem if options[:lint_problem] == :correctness
      introduce_style_problem if options[:lint_problem] == :style
   end

    def ruby_project
      run_simple('git clone --quiet https://github.com/opscode/mixlib-shellout.git')
      cd('mixlib-shellout')
      run_simple('git checkout 3a72a18a9151b160cea1e47f226fc45ba295ed8e') #Ok
      #run_simple('git checkout d67c9a9494c74e6443262024d0e46e83df1af6c6') #Broken
      write_file 'Gemfile', %q{
        source :rubygems
        gemspec :name => "mixlib-shellout"

        group(:test) do

          gem "rspec_junit_formatter"
          gem 'awesome_print'

        end

        group(:kitchen) do
           # needed until Chef 0.10.10 ships
          gem "chef", :git => "https://github.com/opscode/chef.git", :ref => "ba4d58f4223"
          gem "test-kitchen", :path => '../../..'
        end
      }
    end

    def define_integration_tests(options={})
      options = {
        :project_type => 'cookbook',
        :name => 'apache2',
        :configurations => []
      }.merge(options)

      case options[:project_type]
        when "project"
          write_file "#{File.join(options[:name], 'Kitchenfile')}", %Q{
            integration_test "mixlib-shellout" do
              language 'ruby'
              runner 'vagrant'
              runtimes ['1.8.7','1.9.2']
              install 'bundle install --without kitchen'
              script 'bundle exec rspec spec'
            #{'end' unless options[:malformed]}
          }
        when "cookbook"
          # TODO: Template this properly
          config = %Q{cookbook "#{options[:name]}" do\n}
          config << %Q{  configuration "default"\n}
          if options[:name] == 'apache2'
            config << %Q{run_list_extras ['apache2_test::setup']\n}
          end
          config << 'end' unless options[:malformed]
          write_file "#{options[:name]}/test/kitchen/Kitchenfile", config
        else
          fail "Unrecognised project type: #{options[:project_type]}"
      end
    end

    def run_integration_tests
      run_simple(unescape("bundle install"))
      run_simple(unescape("bundle exec kitchen test"), false)
    end

    def kitchenfile_error_shown?
      !! (all_output =~ /Your Kitchenfile could not be loaded. Please check it for errors./)
    end

    def lint_correctness_error_shown?
      !! (all_output =~ /Your cookbook had lint failures./)
    end

    def syntax_error_shown?
      !! (all_output =~ %r{FATAL: Cookbook file recipes/default.rb has a ruby syntax error})
    end

    def tests_run?
      !! (all_output =~ /passed/)
    end

    private

    def clone_and_merge_repositories
      run_simple('git clone --quiet git://github.com/opscode-cookbooks/apache2.git')
      cd('apache2')
      run_simple('git checkout 3ceb3d31ea20ea1fa0c7657871e9b3dd43c31804')
      run_simple('git clone git://github.com/kotiri/apache2_test.git test/kitchen/cookbooks/apache2_test')
      run_simple('mv test/kitchen/cookbooks/apache2_test/features test/features')
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
           # needed until Chef 0.10.10 ships
          gem "chef", :git => "https://github.com/opscode/chef.git", :ref => "ba4d58f4223"
          gem "test-kitchen", :path => '../../../..'
        end
      }
    end

    def add_test_setup_recipe
      write_file 'test/kitchen/cookbooks/apache2_test/recipes/setup.rb', %q{
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

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

require 'test-kitchen/environment'
require 'test-kitchen/ui'
require 'mixlib/cli'

module TestKitchen
  module CLI
    class Kitchen
      include Mixlib::CLI

      option :platform,
        :long  => "--platform PLATFORM",
        :description => "The platform to use. If not specified tests will be run against all platforms.",
        :default => nil

      option :configuration,
        :long  => "--configuration CONFIG",
        :description => "The project configuration to test. Defaults to all configurations."

      option :runner,
        :short => "-r RUNNER",
        :long => "--runner RUNNER",
        :description => "The underlying virtualization platform to test with."

      option :teardown,
        :boolean => true,
        :default => false,
        :long => "--teardown",
        :description => "Teardown test nodes between runs."

      option :help,
        :short => "-h",
        :long => "--help",
        :description => "Show this message",
        :on => :tail,
        :boolean => true,
        :show_options => true,
        :exit => 0

      attr_accessor :runner
      attr_accessor :env
      attr_accessor :ui

      def command_help?
        ARGV.last == '--help'
      end

      def scaffolding?
        ARGV == ['init']
      end

      def run
        validate_and_parse_options
        quiet_traps
        Kitchen.run(ARGV, options)
        exit 0
      end

      def initialize(argv=[])
        $stdout.sync = true
        $stderr.sync = true
        super()
        parse_options(argv)
        @ui = TestKitchen::UI.new(STDOUT, STDERR, STDIN, {})

        # TODO: Move this out of the constructor
        load_environment unless command_help? || scaffolding?
      end

      def load_environment
        @env = TestKitchen::Environment.new(:ui => @ui).tap{|e| e.load!}
      end

      def runner
        @runner ||= begin
          # CLI option takes precedence, then project
          runner_name = config[:runner] || env.project.runner || env.default_runner
          runner_class = TestKitchen::Runner.targets[runner_name]
          runner = runner_class.new(env, config)
        end
      end

      # Class Methods

      def self.run(argv, options={})
        load_commands
        subcommand_class = Kitchen.subcommand_class_from(argv)
        subcommand_class.options = options.merge!(subcommand_class.options)

        instance = subcommand_class.new(ARGV)
        instance.run
      end

      def self.load_commands
        @commands_loaded ||= begin
          if subcommand_files = Dir[File.join(TestKitchen.source_root, 'lib', 'test-kitchen', 'cli', '*.rb')]
            subcommand_files.each { |subcommand| Kernel.load subcommand.to_s }
          end
          true
        end
      end

      NO_COMMAND_GIVEN = "You need to pass a sub-command (e.g., kitchen SUB-COMMAND)\n"

      # BEGIN CARGO CULT FROM Chef::Knife
      def self.inherited(subclass)
        unless subclass.unnamed?
          subcommands[subclass.snake_case_name] = subclass
        end
      end

      def self.subcommands
        @@subcommands ||= {}
      end

      def self.subcommand_category
        @category || snake_case_name.split('_').first unless unnamed?
      end

      def self.snake_case_name
        convert_to_snake_case(name.split('::').last) unless unnamed?
      end

      def self.convert_to_snake_case(str, namespace=nil)
        str = str.dup
        str.sub!(/^#{namespace}(\:\:)?/, '') if namespace
        str.gsub!(/[A-Z]/) {|s| "_" + s}
        str.downcase!
        str.sub!(/^\_/, "")
        str
      end

      # Does this class have a name? (Classes created via Class.new don't)
      def self.unnamed?
        name.nil? || name.empty?
      end

      def self.subcommands_by_category
        unless @subcommands_by_category
          @subcommands_by_category = Hash.new { |hash, key| hash[key] = [] }
          subcommands.each do |snake_cased, klass|
            @subcommands_by_category[klass.subcommand_category] << snake_cased
          end
        end
        @subcommands_by_category
      end

      # Print the list of subcommands knife knows about. If +preferred_category+
      # is given, only subcommands in that category are shown
      def self.list_commands(preferred_category=nil)
        load_commands

        category_desc = preferred_category ? preferred_category + " " : ''
        $stdout.puts "Available #{category_desc}subcommands: (for details, kitchen SUB-COMMAND --help)\n\n"

        if preferred_category && subcommands_by_category.key?(preferred_category)
          commands_to_show = {preferred_category => subcommands_by_category[preferred_category]}
        else
          commands_to_show = subcommands_by_category
        end

        commands_to_show.sort.each do |category, commands|
          next if category =~ /deprecated/i
          $stdout.puts "** #{category.upcase} COMMANDS **"
          commands.each do |command|
            $stdout.puts subcommands[command].banner if subcommands[command]
          end
          $stdout.puts
        end
      end

      def self.subcommand_class_from(args)
        command_words = args.select {|arg| arg =~ /^(([[:alnum:]])[[:alnum:]\_\-]+)$/ }

        subcommand_class = nil

        while ( !subcommand_class ) && ( !command_words.empty? )
          snake_case_class_name = command_words.join("_")
          unless subcommand_class = subcommands[snake_case_class_name]
            command_words.pop
          end
        end
        # see if we got the command as e.g., knife node-list
        subcommand_class ||= subcommands[args.first.gsub('-', '_')]
        subcommand_class || subcommand_not_found!(args)
      end

      # :nodoc:
      # Error out and print usage. probably becuase the arguments given by the
      # user could not be resolved to a subcommand.
      def self.subcommand_not_found!(args)
        $stderr.puts "Cannot find sub command for: '#{args.join(' ')}'"
        list_commands
        exit 10
      end
      # END CARGO CULT FROM Chef::Knife

      private

      # BEGIN CARGO CULT FROM Chef::Application::Knife
      def quiet_traps
        trap("TERM") do
          exit 1
        end

        trap("INT") do
          exit 2
        end
      end

      def validate_and_parse_options
        # Checking ARGV validity *before* parse_options because parse_options
        # mangles ARGV in some situations
        if no_command_given?
          print_help_and_exit(1, NO_COMMAND_GIVEN)
        elsif no_subcommand_given?
          if (want_help? || want_version?)
            print_help_and_exit
          else
            print_help_and_exit(2, NO_COMMAND_GIVEN)
          end
        end
      end

      def no_subcommand_given?
        ARGV[0] =~ /^-/
      end

      def no_command_given?
        ARGV.empty?
      end

      def want_help?
        ARGV[0] =~ /^(--help|-h)$/
      end

      def want_version?
        ARGV[0] =~ /^(--version|-v)$/
      end

      def print_help_and_exit(exitcode=1, fatal_message=nil)
        $stderr.puts(fatal_message) if fatal_message
        puts self.opt_parser
        puts
        TestKitchen::CLI::Kitchen.list_commands
        exit exitcode
      end
      # END CARGO CULT FROM Chef::Application::Knife
    end
  end
end

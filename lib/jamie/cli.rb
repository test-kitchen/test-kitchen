# -*- encoding: utf-8 -*-

require 'thor'

require 'jamie'

module Jamie

  # The command line runner for Jamie.
  class CLI < Thor

    include Thor::Actions

    # Constructs a new instance.
    def initialize(*args)
      super
      @config = Jamie::Config.new(ENV['JAMIE_YAML'])
    end

    desc "list (all ['REGEX']|[INSTANCE])", "List all instances"
    def list(*args)
      result = parse_subcommand(args[0], args[1])
      say Array(result).map{ |i| i.name }.join("\n")
    end

    [:create, :converge, :setup, :verify, :test, :destroy].each do |action|
      desc(
        "#{action} (all ['REGEX']|[INSTANCE])",
        "#{action.capitalize} one or more instances"
      )
      define_method(action) { |*args| exec_action(action) }
    end

    desc "version", "Print Jamie's version information"
    def version
      say "Jamie version #{Jamie::VERSION}"
    end
    map %w(-v --version) => :version

    desc "console", "Jamie Console!"
    def console
      require 'pry'
      Pry.start(@config, :prompt => pry_prompts)
    rescue LoadError => e
      warn %{Make sure you have the pry gem installed. You can install it with:}
      warn %{`gem install pry` or including 'gem "pry"' in your Gemfile.}
      exit 1
    end

    desc "init", "does the world"
    def init
      create_file ".jamie.yml", default_yaml
      append_to_file("Rakefile", <<-RAKE.gsub(/ {8}/, '')) if init_rakefile?

        begin
          require 'jamie/rake_tasks'
          Jamie::RakeTasks.new
        rescue LoadError
          puts ">>>>> Jamie gem not loaded, omitting tasks" unless ENV['CI']
        end
      RAKE
      append_to_file("Thorfile", <<-THOR.gsub(/ {8}/, '')) if init_thorfile?

        begin
          require 'jamie/thor_tasks'
          Jamie::ThorTasks.new
        rescue LoadError
          puts ">>>>> Jamie gem not loaded, omitting tasks" unless ENV['CI']
        end
      THOR
      empty_directory "test/integration/standard" if init_test_dir?
      append_to_gitignore(".jamie/")
      append_to_gitignore(".jamie.local.yml")
      add_plugins
    end

    private

    attr_reader :task

    def exec_action(action)
      @task = action
      result = parse_subcommand(args[0], args[1])
      Array(result).each { |instance| instance.send(task) }
    end

    def parse_subcommand(name_or_all, regexp)
      if name_or_all.nil? || (name_or_all == "all" && regexp.nil?)
        get_all_instances
      elsif name_or_all == "all" && regexp
        get_filtered_instances(regexp)
      elsif name_or_all != "all" && regexp.nil?
        get_instance(name_or_all)
      else
        die task, "Invalid invocation."
      end
    end

    def get_all_instances
      result = @config.instances
      if result.empty?
        die task, "No instances defined"
      else
        result
      end
    end

    def get_filtered_instances(regexp)
      result = @config.instances.get_all(/#{regexp}/)
      if result.empty?
        die task, "No instances for regex `#{regexp}', try running `jamie list'"
      else
        result
      end
    end

    def get_instance(name)
      result = @config.instances.get(name)
      if result.nil?
        die task, "No instance `#{name}', try running `jamie list'"
      end
      result
    end

    def die(task, msg)
      error "\n#{msg}\n\n"
      help(task)
      exit 1
    end

    def pry_prompts
      [ proc { |target_self, nest_level, pry|
          [ "[#{pry.input_array.size}] ",
            "jc(#{Pry.view_clip(target_self.class)})",
            "#{":#{nest_level}" unless nest_level.zero?}> "
          ].join
        },
        proc { |target_self, nest_level, pry|
          [ "[#{pry.input_array.size}] ",
            "jc(#{Pry.view_clip(target_self.class)})",
            "#{":#{nest_level}" unless nest_level.zero?}* "
          ].join
        }
      ]
    end

    def default_yaml
      url_base = "https://opscode-vm.s3.amazonaws.com/vagrant/boxes"
      platforms = [
        { :n => 'ubuntu', :vers => %w(12.04 10.04), :rl => "recipe[apt]" },
        { :n => 'centos', :vers => %w(6.3 5.8), :rl => "recipe[yum::epel]" }
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
      cookbook_name = MetadataChopper.extract('metadata.rb').first
      run_list = cookbook_name ? "recipe[#{cookbook_name}]" : nil
      attributes = cookbook_name ? { cookbook_name => nil } : nil

      { 'default_driver' => 'vagrant',
        'platforms' => platforms,
        'suites' => [
          { 'name' => 'standard',
            'run_list' => Array(run_list),
            'attributes' => attributes
          }
        ]
      }.to_yaml
    end

    def init_rakefile?
      File.exists?("Rakefile") &&
        IO.readlines("Rakefile").grep(%r{require 'jamie/rake_tasks'}).empty?
    end

    def init_thorfile?
      File.exists?("Thorfile") &&
        IO.readlines("Thorfile").grep(%r{require 'jamie/thor_tasks'}).empty?
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
        append_to_file("Gemfile", %{gem '#{plugin}', :group => :integration\n})
        say "You must run `bundle install' to fetch any new gems.", :red
      end
    end

    def list_plugins
      require 'rubygems/spec_fetcher'
      req = Gem::Requirement.default
      dep = Gem::Deprecate.skip_during { Gem::Dependency.new(/guard-/i, req) }
      fetcher = Gem::SpecFetcher.fetcher

      specs = fetcher.find_matching(dep, false, false, false)
      specs = specs.map { |t| t.first }.map { |t| t[0, 2] }.
        sort { |x,y| x[0] <=> y[0] }
      specs = specs[0, 49].push(["...", "..."]) if specs.size > 49
      specs = specs.unshift(["Gem Name", "Latest Stable Release"])
      print_table(specs, :indent => 4)
    end

    # A rather insane and questionable class to quickly consume a metadata.rb
    # file and return the cookbook name and version attributes.
    #
    # @see https://twitter.com/fnichol/status/281650077901144064
    # @see https://gist.github.com/4343327
    class MetadataChopper < Hash

      # Return an Array containing the cookbook name and version attributes,
      # or nil values if they could not be parsed.
      #
      # @param metadata_file [String] path to a metadata.rb file
      # @return [Array<String>] array containing the cookbook name and version
      #   attributes or nil values if they could not be determined
      def self.extract(metadata_file)
        mc = new(File.expand_path(metadata_file))
        [ mc[:name], mc[:version] ]
      end

      # Creates a new instances and loads in the contents of the metdata.rb
      # file. If you value your life, you may want to avoid reading the
      # implementation.
      #
      # @param metadata_file [String] path to a metadata.rb file
      def initialize(metadata_file)
        eval(IO.read(metadata_file), nil, metadata_file)
      end

      def method_missing(meth, *args, &block)
        self[meth] = args.first
      end
    end
  end
end

require 'hashr'
require 'pathname'
require 'yajl'

module TestKitchen

  class Environment

    attr_reader :root_path
    attr_reader :tmp_path
    attr_reader :cache_path
    attr_reader :config
    attr_reader :ui
    attr_reader :kitchenfile_name

    KITCHEN_SUBDIRS = [".", "kitchen", "test/kitchen"]

    def initialize(options={})

      options[:kitchenfile_name] ||= []
      options[:kitchenfile_name] = [options[:kitchenfile_name]] if !options[:kitchenfile_name].is_a?(Array)
      options[:kitchenfile_name] += ["Kitchenfile", "kitchenfile"]
      @kitchenfile_name = options[:kitchenfile_name]

      root_path ||
        (raise ArgumentError,
          "Could not locate a Kitchenfile at [#{KITCHEN_SUBDIRS.map{|sub| File.join(Dir.pwd, sub)}.join(', ')}]")

      @tmp_path = root_path.join('.kitchen')
      @cache_path = tmp_path.join('.cache')
      @ui = options[:ui]
      @projects = []

      setup_tmp_path
      load! # we may want to call this explicitly
    end

    # Inspired by Vagrant::Environment.root_path...danke Mitchell!
    #
    # The root path is the path where the top-most (loaded last)
    # Vagrantfile resides. It can be considered the project root for
    # this environment.
    #
    # @return [String]
    def root_path
      return @root_path if defined?(@root_path)

      KITCHEN_SUBDIRS.each do |dir|
        path = Pathname.new(Dir.pwd).join(dir)
        found = kitchenfile_name.find do |rootfile|
          path.join(rootfile).exist?
        end
        @root_path = path if found
      end

      @root_path
    end

    def platforms
      if platforms = config['platforms']
        platforms
      else
        {}
      end
    end

    def projects
      @projects
    end

    def create_tmp_file(file_name, contents)
      File.open(tmp_path.join(file_name), 'w') do |f|
        f.write(contents)
      end
    end

    def cookbook_paths
      @cookbook_paths ||= begin
        p = [tmp_path.join('cookbooks').to_s]
        p << root_path.join('cookbooks').to_s if root_path.join('cookbooks').exist?
        p
      end
    end

    def setup_tmp_path
      # pre-create required dirs
      [ tmp_path, cache_path ].each do |dir|
        FileUtils.mkdir_p(dir)
      end
    end

    #---------------------------------------------------------------
    # Load Methods
    #---------------------------------------------------------------

    # Returns a boolean representing if the environment has been
    # loaded or not.
    #
    # @return [Bool]
    def loaded?
      !!@loaded
    end

    def load!
      if !loaded?
        @loaded = true
        load_old_json_config
        load_kitchenfiles
      end

      self
    end

    def self.current
      @@current
    end

    def self.current=(current)
      @@current = current
    end

    private

    # Inspired by Vagrant::Environment.find_vagrantfile...danke Mitchell!
    #
    # Finds the Kitchenfile in the given directory.
    #
    # @param [Pathname] path Path to search in.
    # @return [Pathname]
    def find_kitchenfile(search_path)
      @kitchenfile_name.each do |kitchenfile|
        current_path = search_path.join(kitchenfile)
        return current_path if current_path.exist?
      end

      nil
    end

    # TODO - remove when kitchen file does everything
    def load_old_json_config
      config = Hash.new

      # config files that ship in test-kitchen gem
      config_files = Dir[File.join(TestKitchen.source_root, 'config', '**', '*.json')]
      # project/user specific config files
      config_files << Dir[File.join(root_path, 'config', '**', '*.json')]

      config_files.flatten.each do |file|
        File.open(file) do |json|
          config = config.deep_merge(Yajl::Parser.parse(json.read))
        end
      end
      @config = config

      if config['projects']
        projects += config['projects'].map do |name, values|
          Project.from_hash(values.merge('name' => name))
        end
      end
    end

    def load_kitchenfiles
      # load Kitchenfile that ships with gem...seeds defaults
      kitchenfiles = [File.expand_path("config/Kitchenfile", TestKitchen.source_root)]
      # Load the user's Kitchenfile
      kitchenfiles << find_kitchenfile(root_path) if root_path

      kitchenfiles.flatten.each do |kitchenfile|
        dsl_file = DSL::File.new
        projects << dsl_file.load(kitchenfile)
      end
    end

  end
end

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
    attr_accessor :project

    KITCHEN_SUBDIRS = [".", "kitchen", "test/kitchen"]

    def initialize(options={})

      options[:kitchenfile_name] ||= []
      options[:kitchenfile_name] = [options[:kitchenfile_name]] if !options[:kitchenfile_name].is_a?(Array)
      options[:kitchenfile_name] += ["Kitchenfile", "kitchenfile"]
      @kitchenfile_name = options[:kitchenfile_name]

      if options[:ignore_kitchenfile]
        @root_path = Pathname.new(Dir.pwd)
      else
        root_path ||
          (raise ArgumentError,
            "Could not locate a Kitchenfile at [#{KITCHEN_SUBDIRS.map{|sub| File.join(Dir.pwd, sub)}.join(', ')}]")
      end

      @tmp_path = root_path.join('.kitchen')
      @cache_path = tmp_path.join('.cache')
      @ui = options[:ui]

      setup_tmp_path
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
      @platforms ||= {}
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

    def load_kitchenfiles
      # load Kitchenfile that ships with gem...seeds defaults
      kitchenfiles = [File.expand_path("config/Kitchenfile", TestKitchen.source_root)]
      # Load the user's Kitchenfile
      kitchenfiles << find_kitchenfile(root_path) if root_path

      kitchenfiles.flatten.each do |kitchenfile|
        dsl_file = DSL::File.new
        dsl_file.load(kitchenfile, self)
      end
    end

  end
end

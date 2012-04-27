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

    def initialize(options={})
      # TODO - make this locate the Kitchenfile by default
      @root_path = Pathname.new(File.expand_path(options[:root_path] || Dir.pwd))
      @tmp_path = @root_path.join('.kitchen')
      @cache_path = @tmp_path.join('.cache')
      @ui = options[:ui]

      # pre-create required dirs
      [ @tmp_path, @cache_path ].each do |dir|
        FileUtils.mkdir_p(dir)
      end
      load!
    end

    def platforms
      if platforms = config['platforms']
        platforms
      else
        {}
      end
    end

    def projects
      @projects ||= if config['projects']
        config['projects'].map do |name, values|
          Project.from_hash(values.merge('name' => name))
        end
      else
        []
      end
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

        load_config!
      end

      self
    end

    # TODO - move from JSON to Kitchenfiles
    def load_config!
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
    end

  end
end

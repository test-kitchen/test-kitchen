require 'test-kitchen/cli'
require 'test-kitchen/project'
require 'test-kitchen/vagrant'
require 'test-kitchen/version'
require 'hashr'
require 'pathname'
require 'yajl'

module TestKitchen

  # The project root is the path to the root directory of the
  # current test-kitchen project
  def self.project_root
    @project_root ||= Dir.pwd
  end

  def self.project_name
    @project_name ||= Pathname.new(TestKitchen.project_root).basename.to_s
  end

  def self.setup
    eval IO.read(File.join(TestKitchen.source_root, 'config', 'Vagrantfile'))
  end

  # The source root is the path to the root directory of
  # the test-kitchen gem.
  def self.source_root
    @source_root ||= Pathname.new(File.expand_path('../', __FILE__))
  end

  def self.host_cache_path
    @cache_path ||= begin
      path = File.join(TestKitchen.project_root, '.cache')
      FileUtils.mkdir_p(path)
      path
    end
  end

  def self.guest_cache_path
    "/tmp/cache"
  end

  def self.test_root
    "/vagrant/tests"
  end

  def self.external_config
    @external_config || begin
      external_config = Hash.new

      # config files that ship in test-kitchen gem
      config_files = Dir[File.join(TestKitchen.source_root, 'config', '**', '*.json')]
      # project/user specific config files
      config_files << Dir[File.join(TestKitchen.project_root, 'config', '**', '*.json')]

      config_files.flatten.each do |file|
        File.open(file) do |json|
          external_config = external_config.deep_merge(Yajl::Parser.parse(json.read))
        end
      end
      external_config
    end
  end

  def self.platforms
    if platforms = external_config['platforms']
      platforms
    else
      {}
    end
  end

  def self.projects
    @projects ||= if external_config['projects']
      external_config['projects'].map do |name, values|
        Project.from_hash(values.merge('name' => name))
      end
    else
      []
    end
  end

end

module TestKitchen

  # A configuration that is being tested
  module Configuration
    attr_reader :name
    attr_writer :language, :runtimes, :script
    attr_accessor :rvm, :repository, :revision, :memory, :vm

    def initialize(name)
      raise ArgumentError, "Project name must be specified" if name.nil? || name.empty?
      @name = name
    end

    def language
      @language ||= 'ruby'
    end

    def runtimes
      @runtimes ||=
        if language == 'ruby'
          rvm ? rvm : ['1.9.2']
        else
          []
        end
    end

    def script
      @script ||= 'rspec spec'
    end

  end

  class Project
    include Configuration
    def self.from_hash(hash)
      project = self.new(hash['name'])
      hash.each{|key,value| project.send("#{key}=", value) unless key == 'name'}
      project
    end
  end
end

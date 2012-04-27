require 'chef/mixin/params_validate'

module TestKitchen

  # A configuration that is being tested
  class Configuration

    include Chef::Mixin::ParamsValidate

    attr_reader :name
    attr_writer :language, :runtimes, :install, :script, :rvm
    attr_accessor :vm

    def initialize(name, &block)
      raise ArgumentError, "Project name must be specified" if name.nil? || name.empty?
      @name = name
      @configurations = []
      instance_eval(&block) if block_given?
    end

    def configuration(name)
      @configurations << Configuration.new(name)
    end

    def configurations
      @configurations
    end

    def platforms
      @platforms ||= []
    end

    def exclude(exclusion)
      if exclusion.key?(:platform)
        platforms.delete(exclusion[:platform])
      end
    end

    def language(arg=nil)
      set_or_return(:language, arg, :default => 'ruby')
    end

    def runtimes(arg=nil)
      set_or_return(:runtimes, arg, :default =>
        if language == 'ruby'
          rvm ? rvm : ['1.9.2']
        else
          []
        end)
    end

    def install(arg=nil)
      set_or_return(:install, arg,
        :default => language == 'ruby' ? 'bundle install' : '')
    end

    def script(arg=nil)
      set_or_return(:script, arg, :default => 'rspec spec')
    end

    def rvm(arg=nil)
      set_or_return(:rvm, arg, {})
    end

    def repository(arg=nil)
      set_or_return(:repository, arg, {})
    end

    def revision(arg=nil)
      set_or_return(:revision, arg, {})
    end

    def memory(arg=nil)
      set_or_return(:memory, arg, {})
    end

  end

  class Project < Configuration
    def self.from_hash(hash)
      project = self.new(hash['name'])
      hash.each{|key,value| project.send("#{key}=", value) unless key == 'name'}
      project
    end
  end

  class CookbookProject < Project
    def lint(arg=nil)
      set_or_return(:lint, arg, {:default => true})
    end
  end

end

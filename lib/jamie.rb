# -*- encoding: utf-8 -*-

require 'hashie/dash'
require 'mixlib/shellout'
require 'yaml'

require "jamie/version"

module Jamie
  class Platform < Hashie::Dash
    property :name, :required => true
    property :vagrant_box
    property :vagrant_box_url
    property :base_run_list, :default => []
  end

  class Suite < Hashie::Dash
    property :name, :required => true
    property :run_list, :required => true
    property :json, :default => Hash.new
  end

  class Config
    attr_writer :yaml
    attr_writer :platforms
    attr_writer :suites
    attr_writer :backend
    attr_writer :log_level
    attr_writer :data_bags_base_path

    def yaml
      @yaml ||= File.join(Dir.pwd, '.jamie.yml')
    end

    def platforms
      @platforms ||=
        Array(yaml_data["platforms"]).map { |hash| Platform.new(hash) }
    end

    def suites
      @suites ||=
        Array(yaml_data["suites"]).map { |hash| Suite.new(hash) }
    end

    def backend
      @backend ||= backend_for(yaml_data["backend"] || "vagrant")
    end

    def log_level
      @log_level ||= :info
    end

    def data_bags_base_path
      default_path = File.join(Dir.pwd, 'test/integration')

      @data_bags_path ||= File.directory?(default_path) ? default_path : nil
    end

    def instances
      result = []
      suites.each do |suite|
        platforms.each do |platform|
          result << instance_name(suite, platform)
        end
      end
      result
    end

    private

    def yaml_data
      @yaml_data ||= YAML.load_file(yaml)
    end

    def instance_name(suite, platform)
      "#{suite.name}-#{platform.name}".gsub(/_/, '-').gsub(/\./, '')
    end

    def backend_for(backend)
      klass = Jamie::Backend.const_get(backend.capitalize)
      klass.new
    end
  end

  module Backend
    class CommandFailed < StandardError ; end

    class Vagrant
      def up(instance)
        exec! "vagrant up #{instance}"
      rescue Mixlib::ShellOut::ShellCommandFailed => ex
        raise CommandFailed, ex.message
      end

      def destroy(instance)
        exec! "vagrant destroy #{instance} -f"
      rescue Mixlib::ShellOut::ShellCommandFailed => ex
        raise CommandFailed, ex.message
      end

      def exec!(cmd)
        puts "-----> [vagrant command] #{cmd}"
        shellout = Mixlib::ShellOut.new(
          cmd, :live_stream => STDOUT, :timeout => 60000
        )
        shellout.run_command
        puts "-----> Command '#{cmd}' ran in #{shellout.execution_time} seconds."
        shellout.error!
      end
    end
  end
end

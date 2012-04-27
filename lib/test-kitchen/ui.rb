
module TestKitchen
  class UI

    attr_reader :stdout
    attr_reader :stderr
    attr_reader :stdin

    def initialize(stdout, stderr, stdin, config)
      @stdout, @stderr, @stdin, @config = stdout, stderr, stdin, config
    end

    def highline
      @highline ||= begin
        require 'highline'
        HighLine.new
      end
    end

    # Prints a message to stdout. Aliased as +info+ for compatibility with
    # the logger API.
    def msg(message, *colors)
      if colors
        message = color(message, *colors)
      end
      stdout.puts message
    end

    alias :info :msg

    # Prints a msg to stderr. Used for warn, error, and fatal.
    def err(message)
      stderr.puts message
    end

    # Print a warning message
    def warn(message)
      err("#{color('WARNING:', :yellow, :bold)} #{message}")
    end

    # Print an error message
    def error(message)
      err("#{color('ERROR:', :red, :bold)} #{message}")
    end

    # Print a message describing a fatal error.
    def fatal(message)
      err("#{color('FATAL:', :red, :bold)} #{message}")
    end

    def color(string, *colors)
      highline.color(string, *colors)
    end

  end
end

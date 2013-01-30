# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fileutils'
require 'logger'

module Kitchen

  # Logging implementation for Kitchen. By default the console/stdout output
  # will be displayed differently than the file log output. Therefor, this
  # class wraps multiple loggers that conform to the stdlib `Logger` class
  # behavior.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class Logger

    include ::Logger::Severity

    attr_reader :logdev

    def initialize(options = {})
      color = options[:color] || :bright_white

      @loggers = []
      @loggers << @logdev = logdev_logger(options[:logdev]) if options[:logdev]
      @loggers << stdout_logger(options[:stdout], color) if options[:stdout]
      @loggers << stdout_logger(STDOUT, color) if @loggers.empty?

      self.progname = options[:progname] || "Kitchen"
      self.level = options[:level] || default_log_level
    end

    %w{ level progname datetime_format debug? info? error? warn? fatal?
    }.each do |meth|
      define_method(meth) do |*args|
        @loggers.first.public_send(meth, *args)
      end
    end

    %w{ level= progname= datetime_format= add <<
        banner debug info error warn fatal unknown close
    }.map(&:to_sym).each do |meth|
      define_method(meth) do |*args|
        result = nil
        @loggers.each { |l| result = l.public_send(meth, *args) }
        result
      end
    end

    private

    def default_log_level
      Util.to_logger_level(Kitchen::DEFAULT_LOG_LEVEL)
    end

    def stdout_logger(stdout, color)
      logger = StdoutLogger.new(stdout)
      logger.formatter = proc do |severity, datetime, progname, msg|
        Color.colorize("#{msg}\n", color)
      end
      logger
    end

    def logdev_logger(filepath_or_logdev)
      LogdevLogger.new(resolve_logdev(filepath_or_logdev))
    end

    def resolve_logdev(filepath_or_logdev)
      if filepath_or_logdev.is_a? String
        FileUtils.mkdir_p(File.dirname(filepath_or_logdev))
        file = File.open(File.expand_path(filepath_or_logdev), "ab")
        file.sync = true
        file
      else
        filepath_or_logdev
      end
    end

    # Internal class which adds a #banner method call that displays the
    # message with a callout arrow.
    class LogdevLogger < ::Logger

      alias_method :super_info, :info

      def <<(msg)
        msg =~ /\n/ ? msg.split("\n").each { |l| format_line(l) } : super
      end

      def banner(msg = nil, &block)
        super_info("-----> #{msg}", &block)
      end

      private

      def format_line(line)
        case line
        when %r{^-----> } then banner(line.gsub(%r{^[ >-]{6} }, ''))
        when %r{^>>>>>> } then error(line.gsub(%r{^[ >-]{6} }, ''))
        when %r{^       } then info(line.gsub(%r{^[ >-]{6} }, ''))
        else info(line)
        end
      end
    end

    # Internal class which reformats logging methods for display as console
    # output.
    class StdoutLogger < LogdevLogger

      def debug(msg = nil, &block)
        super("D      #{msg}", &block)
      end

      def info(msg = nil, &block)
        super("       #{msg}", &block)
      end

      def warn(msg = nil, &block)
        super("$$$$$$ #{msg}", &block)
      end

      def error(msg = nil, &block)
        super(">>>>>> #{msg}", &block)
      end

      def fatal(msg = nil, &block)
        super("!!!!!! #{msg}", &block)
      end
    end
  end
end
